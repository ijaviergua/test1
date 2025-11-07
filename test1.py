import sys
import json
import requests
import urllib3
from requests.exceptions import RequestException

# ======== Configuration (edit these) ========
# APIC management IP or hostname (no protocol, no trailing slash)
APIC_IP = "172.16.100.65"

# APIC credentials
USERNAME = "admin"
PASSWORD = "Cisco!123"

# SSL verification: set to True if you have valid certs
VERIFY_SSL = False

# Request timeout in seconds
TIMEOUT = 10
# ============================================

# Suppress SSL warnings when VERIFY_SSL is False
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def apic_url(path: str) -> str:
    return f"https://{APIC_IP}{path}"


def login(session: requests.Session) -> None:
    url = apic_url("/api/aaaLogin.json")
    payload = {"aaaUser": {"attributes": {"name": USERNAME, "pwd": PASSWORD}}}
    resp = session.post(url, json=payload, verify=VERIFY_SSL, timeout=TIMEOUT)
    resp.raise_for_status()
    data = resp.json()

    # Check for APIC error response
    if isinstance(data, dict) and data.get("imdata"):
        first = data["imdata"][0]
        if "error" in first:
            err = first["error"]["attributes"]
            raise RuntimeError(f"Login failed: {err.get('text')}")


def get_tenants(session: requests.Session):
    url = apic_url("/api/class/fvTenant.json")
    resp = session.get(url, verify=VERIFY_SSL, timeout=TIMEOUT)
    resp.raise_for_status()
    data = resp.json()

    tenants = []
    for item in data.get("imdata", []):
        obj = item.get("fvTenant")
        if not obj:
            continue
        attr = obj.get("attributes", {})
        tenants.append(
            {
                "name": attr.get("name"),
                "dn": attr.get("dn"),
                "descr": attr.get("descr", ""),
            }
        )
    return tenants


def main():
    try:
        session = requests.Session()
        login(session)
        tenants = get_tenants(session)

        if not tenants:
            print("No tenants found.")
            return

        print(f"Tenants ({len(tenants)}):")
        for t in tenants:
            name = t.get("name", "<unknown>")
            dn = t.get("dn", "")
            descr = t.get("descr", "")
            print(f"- {name} | dn={dn} | descr={descr}")

    except RequestException as e:
        print(f"HTTP error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()