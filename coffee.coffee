FASE 1 Estandarizacion de etiquetas en los COREs

CORE 1 CPD

OBJETIVO [1] tagear la ruta por defecto de ospf en vrf default y vrf 11

 #prefix list para la ruta por defecto
 ip prefix-list DEFAULT seq 5 permit 0.0.0.0/0
 ip prefix-list DEFAULT_VRF11 seq 5 permit 0.0.0.0/0
 
 #route-map 
 route-map DEFAULT permit 10
 match ip address prefix-list DEFAULT
 set tag 653510
 set metric 230
 
 route-map DEFAULT_VRF11 permit 10
 match ip address prefix-list DEFAULT_VRF11
 set tag 654510
 
 router ospf 100
   default-information originate route-map DEFAULT
 
 router ospf 300
   vrf VRF11-INTERNET-DC1
     default-information originate route-map DEFAULT_VRF11

OBJETIVO [2] estandarizar lo tags de redistribucion OSPF <-> BGP en vrf default y vrf 11
 
 # para VRF DEFAULT <<>> BGP_TO_OSPF
 
 # elimina el route map para luego reconfigurarlo
 no route-map BGP_TO_OSPF
 #route-map BGP_TO_OSPF permit 5
 #  match community FROM_FW_EXTERNO_TO_CORE_01
 #  set tag 65350
 #  set metric 230
 #route-map BGP_TO_OSPF permit 10
 #  set tag 65351
 #  set metric 230
 
 # route map que clasifica la ruta por defecto desde firewall
 route-map BGP_TO_OSPF permit 10
   match community FROM_FW_EXTERNO_TO_CORE_01
   match ip address prefix-list DEFAULT
   set tag 6535110
   set metric 230
 # route map que clasifica rutas externas desde firewall
 route-map BGP_TO_OSPF permit 20
   match community FROM_FW_EXTERNO_TO_CORE_01
   set tag 6535111
   set metric 230
 # route map que clasifica rutas externas desde otros origenes
 route-map BGP_TO_OSPF permit 30
   set tag 6535112
   set metric 230

 # para VRF DEFAULT <<>> OSPF_TO_BGP
 
 # elimina el route map para luego reconfigurarlo
 no route-map OSPF_TO_BGP
 #route-map OSPF_TO_BGP deny 5
 #  match tag 65351
 #route-map OSPF_TO_BGP deny 6
 #  match tag 64651
 #route-map OSPF_TO_BGP deny 7
 #  match tag 64652
 #route-map OSPF_TO_BGP deny 8
 #  match tag 65350
 #route-map OSPF_TO_BGP permit 10
 #  match ip address prefix-list REDES_SUMM_GTD
 #  set community 65352:1 65352:2 additive
 #route-map OSPF_TO_BGP permit 15
 #  set community 65352:1
 
 # route map rutas por defecto generados por ospf de cada core
 route-map OSPF_TO_BGP deny 10
   match tag 653510 653520 646510 646520
 # route map external y el resto desde firewall core 1 cpd
 route-map OSPF_TO_BGP deny 20
   match tag 6535110 6535111 6535112 
 # route map external y el resto desde firewall core 2 cpd
 route-map OSPF_TO_BGP deny 30
   match tag 6535210 6535211 6535212
 # route map external y el resto desde firewall core 1 gtd
 route-map OSPF_TO_BGP deny 40
   match tag 6465110 6465111 6465112 6465113
 # route map external y el resto desde firewall core 2 gtd
 route-map OSPF_TO_BGP deny 50
   match tag 6465210 6465211 6465212 6465213
 # route map envia redes aprendidas por ospf a bgp de gtd
 route-map OSPF_TO_BGP permit 60
   match ip address prefix-list REDES_SUMM_GTD
   set community 65351:12
 # route map envia redes aprendidas por ospf a bgp de cdp
 route-map OSPF_TO_BGP permit 70
   set community 65351:11
 
 # para VRF11 <<>> BGP_TO_OSPF

 # elimina el route map para luego reconfigurarlo
 no route-map BGP_TO_OSPF_VRF11
 #route-map BGP_TO_OSPF_VRF11 permit 10
 #  match ip address prefix-list REDIST_BGP_TO_OSPF_VRF11
 #  set tag 65451
 
 # route map que clasifica la ruta por defecto desde firewall
 route-map BGP_TO_OSPF_VRF11 permit 10
   match ip address prefix-list DEFAULT_VRF11
   set tag 6545110
 # route map que clasifica rutas externas desde firewall y otros origenes
 route-map BGP_TO_OSPF_VRF11 permit 20
   set tag 6545111
 
 # para VRF11 <<>> OSPF_TO_BGP
 
 # elimina el route map para luego reconfigurarlo
 no route-map OSPF_TO_BGP_VRF11
 #route-map OSPF_TO_BGP_VRF11 deny 5
 # match tag 65452
 #route-map OSPF_TO_BGP_VRF11 permit 10
 # set community 65451:1
 
 # route map rutas por defecto generados por ospf de cada core
 route-map OSPF_TO_BGP_VRF11 deny 10
   match tag 654510 654520
 # route map external y el resto desde firewall y otros origenes core 1 cpd
 route-map OSPF_TO_BGP_VRF11 deny 20
   match tag 6545110 6545111 
 # route map external y el resto desde firewall y otros origenes core 2 cpd
 route-map OSPF_TO_BGP_VRF11 deny 30
   match tag 6545210 6545211 
 # route map envia redes aprendidas por ospf a bgp de cpd
 route-map OSPF_TO_BGP permit 40
   set community 65451:11

 ---

OBJETIVO [3] estandarizar lo tags de redistribucion OSPF <-> BGP en vrf default en N9KA

 ###
 9500-03N-BBVA-01 - AS IS
  route-map FROM_B2B_C9500-41E-BBVA-02 permit 10
  
  route-map TO_B2B_C9500-41E-BBVA-02 permit 10
  ------------------------------------------------------------------
  
  ip prefix-list Red_Default seq 10 permit 0.0.0.0/0
  
  ip prefix-list SDWAN_MONITOR_OFICINA seq 10 permit 119.177.61.1/32
  
  ip community-list standard FGT_OFICINAS permit 65000:1
  
  route-map FROM_SDWAN_FORTINET_OFICINA deny 10
   description Denegar Red Default del FORTINET
   match ip address prefix-list Red_Default
  
  route-map FROM_SDWAN_FORTINET_OFICINA permit 20
   match community FGT_OFICINAS
   set local-preference 200
   
  route-map TO_SDWAN_FORTINET_OFICINA permit 5
   match ip address prefix-list SDWAN_MONITOR_OFICINA
   set community 65351:1
  
  route-map TO_SDWAN_FORTINET_OFICINA permit 10
  ------------------------------------------------------------------
  
  ip community-list standard FGT_ATMS permit 65001:1
  
  ip prefix-list SDWAN_MONITOR_ATM seq 10 permit 119.177.61.3/32
  
  route-map FROM_SDWAN_FORTINET_ATM deny 10
   description Denegar Red Default del FORTINET
   match ip address prefix-list Red_Default
  
  route-map FROM_SDWAN_FORTINET_ATM permit 20
   match community FGT_ATMS
   set local-preference 200
  
  route-map TO_SDWAN_FORTINET_ATM permit 5
   match ip address prefix-list SDWAN_MONITOR_ATM
   set community 65351:1
  
  route-map TO_SDWAN_FORTINET_ATM permit 10
  ------------------------------------------------------------------
  
  ip community-list standard TO_CORE_BLOCK permit 65351:1
  ip community-list standard TO_CORE_BLOCK permit 65352:1
  
  route-map FROM_N9K-CORE-BBVA-03i-1 permit 10
   set local-preference 200
  
  route-map TO_N9K-CORE-BBVA-03i-1 deny 5
   match community TO_CORE_BLOCK
 ###

 9500-03N-BBVA-01 - TO BE
 
  route-map TO_SDWAN_FORTINET_OFICINA permit 5
   no set community 65351:1
   set community 65526:12
 
  route-map TO_SDWAN_FORTINET_ATM permit 5
   no set community 65351:1
   set community 65526:12
 
  no ip community-list standard TO_CORE_BLOCK permit 65351:1
  no ip community-list standard TO_CORE_BLOCK permit 65352:1
  ip community-list standard TO_CORE_BLOCK permit 65351:11
  ip community-list standard TO_CORE_BLOCK permit 65352:11

OBJETIVO [4] estandarizar lo tags de redistribucion OSPF <-> BGP en vrf default en FW

 Migracion de etiquetas para FW
  65351:1 -> 65351:11
  65352:1 -> 65352:11
  65351:1 -> 65526:12

CORE 2 CPD
 
OBJETIVO [1] tagear la ruta por defecto de ospf en vrf default y vrf 11
 
 ip prefix-list DEFAULT seq 5 permit 0.0.0.0/0
 ip prefix-list DEFAULT_VRF11 seq 5 permit 0.0.0.0/0
 
 route-map DEFAULT permit 10
  match ip address prefix-list DEFAULT
  set tag 653520
  set metric 230

 route-map DEFAULT_VRF11 permit 10
 match ip address prefix-list DEFAULT_VRF11
 set tag 654520
 
 router ospf 100
   default-information originate route-map DEFAULT
 
 router ospf 300
   vrf VRF11-INTERNET-DC1
     default-information originate route-map DEFAULT_VRF11

OBJETIVO [2] estandarizar lo tags de redistribucion OSPF <-> BGP en vrf default y vrf 11

 # para VRF DEFAULT <<>> BGP_TO_OSPF

 # elimina el route map para luego reconfigurarlo
 no route-map BGP_TO_OSPF
 #route-map BGP_TO_OSPF permit 5
 #  match community FROM_FW_EXTERNO_TO_CORE_02
 #  set tag 65350
 #  set metric 240
 #route-map BGP_TO_OSPF permit 10
 #  set tag 65352
 #  set metric 240
 
 # route map que clasifica la ruta por defecto desde firewall
 route-map BGP_TO_OSPF permit 10
   match community FROM_FW_EXTERNO_TO_CORE_02
   match ip address prefix-list DEFAULT
   set tag 6535210
   set metric 240
 # route map que clasifica rutas externas desde firewall
 route-map BGP_TO_OSPF permit 20
   match community FROM_FW_EXTERNO_TO_CORE_02
   set tag 6535211
   set metric 240
 # route map que clasifica rutas externas desde otros origenes
 route-map BGP_TO_OSPF permit 30
   set tag 6535212
   set metric 240
 
 # para VRF DEFAULT <<>> OSPF_TO_BGP
 
 # elimina el route map para luego reconfigurarlo
 no route-map OSPF_TO_BGP
 #route-map OSPF_TO_BGP deny 5
 #  match tag 65351
 #route-map OSPF_TO_BGP deny 6
 #  match tag 64651
 #route-map OSPF_TO_BGP deny 7
 #  match tag 64652
 #route-map OSPF_TO_BGP deny 8
 #  match tag 65350
 #route-map OSPF_TO_BGP permit 10
 #  match ip address prefix-list REDES_SUMM_GTD
 #  set community 65352:1 65352:2 additive
 #route-map OSPF_TO_BGP permit 15
 #  set community 65352:1
 
 # route map rutas por defecto generados por ospf de cada site
 route-map OSPF_TO_BGP deny 10
   match tag 653510 653520 646510 646520
 # route map external y el resto desde firewall core 1 cpd
 route-map OSPF_TO_BGP deny 20
   match tag 6535110 6535111 6535112
 # route map external y el resto desde firewall core 2 cpd
 route-map OSPF_TO_BGP deny 30
   match tag 6535210 6535211 6535212
 # route map external y el resto desde firewall core 1 gtd
 route-map OSPF_TO_BGP deny 40
   match tag 6465110 6465111 6465112 6465113
 # route map external y el resto desde firewall core 2 gtd
 route-map OSPF_TO_BGP deny 50
   match tag 6465210 6465211 6465212 6465213
 # route map envia redes aprendidas por ospf a bgp de gtd
 route-map OSPF_TO_BGP permit 60
   match ip address prefix-list REDES_SUMM_GTD
   set community 65352:12
 # route map envia redes aprendidas por ospf a bgp de cdp
 route-map OSPF_TO_BGP permit 70
   set community 65352:11

 # para VRF11 <<>> BGP_TO_OSPF

 # elimina el route map para luego reconfigurarlo
 no route-map BGP_TO_OSPF_VRF11
 #route-map BGP_TO_OSPF_VRF11 permit 10
 #  match ip address prefix-list REDIST_BGP_TO_OSPF_VRF11
 #  set tag 65452
 
 # route map que clasifica la ruta por defecto desde firewall
 route-map BGP_TO_OSPF_VRF11 permit 10
   match ip address prefix-list DEFAULT_VRF11
   set tag 6545210
 # route map que clasifica rutas externas desde firewall y otros origenes
 route-map BGP_TO_OSPF_VRF11 permit 20
   set tag 6545211
 
 # para VRF11 <<>> OSPF_TO_BGP
 
 # elimina el route map para luego reconfigurarlo
 no route-map OSPF_TO_BGP_VRF11
 #route-map OSPF_TO_BGP_VRF11 deny 5
 #  match tag 65451
 #route-map OSPF_TO_BGP_VRF11 permit 10
 #  set community 65452:1
 
 # route map rutas por defecto generados por ospf de cada core
 route-map OSPF_TO_BGP_VRF11 deny 10
   match tag 654510 654520
 # route map external y el resto desde firewall core 1 cpd
 route-map OSPF_TO_BGP_VRF11 deny 20
   match tag 6545110 6545111 
 # route map external y el resto desde firewall core 2 cpd
 route-map OSPF_TO_BGP_VRF11 deny 30
   match tag 6545210 6545211 
 # route map envia redes aprendidas por ospf a bgp de cpd
 route-map OSPF_TO_BGP permit 40
   set community 65452:11

OBJETIVO [3] estandarizar lo tags de redistribucion OSPF <-> BGP en vrf default en N9KB

 ###
 C9500-41E-BBVA-02 - AS IS
  route-map TO_B2B_C9500-03N-BBVA-01 permit 10
  
  route-map FROM_B2B_C9500-03N-BBVA-01 permit 10
  ------------------------------------------------------------------
  
  ip prefix-list Red_Default seq 10 permit 0.0.0.0/0
  
  ip community-list standard FGT_OFICINAS permit 65000:2
  
  ip prefix-list SDWAN_MONITOR_OFICINA seq 10 permit 119.177.61.2/32
  
  route-map FROM_SDWAN_FORTINET_OFICINA deny 10
   description Denegar Red Default del FORTINET
   match ip address prefix-list Red_Default
  
  route-map FROM_SDWAN_FORTINET_OFICINA permit 20
   match community FGT_OFICINAS
   set local-preference 100
  
  route-map TO_SDWAN_FORTINET_OFICINA permit 5
   match ip address prefix-list SDWAN_MONITOR_OFICINA
   set community 65352:1
  
  route-map TO_SDWAN_FORTINET_OFICINA permit 10
  ------------------------------------------------------------------
  
  ip community-list standard FGT_ATMS permit 65001:2
  
  ip prefix-list SDWAN_MONITOR_ATM seq 10 permit 119.177.61.4/32
  
  route-map FROM_SDWAN_FORTINET_ATM deny 10
   description Denegar Red Default del FORTINET
   match ip address prefix-list Red_Default
  
  route-map FROM_SDWAN_FORTINET_ATM permit 20
   match community FGT_ATMS
   set local-preference 100
  
  route-map TO_SDWAN_FORTINET_ATM permit 5
   match ip address prefix-list SDWAN_MONITOR_ATM
   set community 65352:1
  
  route-map TO_SDWAN_FORTINET_ATM permit 10
  ------------------------------------------------------------------
  
  ip community-list standard TO_CORE_BLOCK permit 65351:1
  ip community-list standard TO_CORE_BLOCK permit 65352:1
  
  route-map TO_N9K-CORE-BBVA-41i-2 deny 5
   match community TO_CORE_BLOCK
  
  route-map TO_N9K-CORE-BBVA-41i-2 permit 10
 ###
 
 C9500-41E-BBVA-02 - TO BE
 
  route-map TO_SDWAN_FORTINET_OFICINA permit 5
   no set community 65352:1
   set community 65526:13
 
  route-map TO_SDWAN_FORTINET_ATM permit 5
   no set community 65352:1
   set community 65526:13
 
  no ip community-list standard TO_CORE_BLOCK permit 65351:1
  no ip community-list standard TO_CORE_BLOCK permit 65352:1
  ip community-list standard TO_CORE_BLOCK permit 65351:11
  ip community-list standard TO_CORE_BLOCK permit 65352:11

OBJETIVO [4] estandarizar lo tags de redistribucion OSPF <-> BGP en vrf default en FW

 Migracion de etiquetas para FW
  65351:1 -> 65351:11
  65352:1 -> 65352:11
  65352:1 -> 65526:13

CORE 1 GTD

OBJETIVO [1] tagear la ruta por defecto de ospf en vrf default y vrf 12

 ip prefix-list DEFAULT seq 5 permit 0.0.0.0/0
 ip prefix-list DEFAULT_VRF12 seq 5 permit 0.0.0.0/0
 
 route-map DEFAULT permit 10
 match ip address prefix-list DEFAULT
 set tag 646510
 set metric 250

 route-map DEFAULT_VRF12 permit 10
 match ip address prefix-list DEFAULT_VRF12
 set tag 647510
 
 router ospf 100
   default-information originate route-map DEFAULT
 
 router ospf 200
   vrf VRF12-INTERNET-DC2
     default-information originate route-map DEFAULT_VRF12

OBJETIVO [2] estandarizar lo tags de redistribucion OSPF <-> BGP en vrf default y vrf 12

 # para VRF DEFAULT <<>> BGP_TO_OSPF

 # elimina el route map para luego reconfigurarlo
 no route-map BGP_TO_OSPF
 #route-map BGP_TO_OSPF permit 5
 #  match community FROM_FW_EXTERNO_TO_CORE_01
 #  set tag 64650
 #  set metric 250
 #route-map BGP_TO_OSPF permit 7
 #  match community FROM_C9400_GTDBBVA_01
 #  set tag 65518
 #route-map BGP_TO_OSPF permit 10
 #  set tag 64651
 #  set metric 250
 
 # route map que clasifica la ruta por defecto desde firewall
 route-map BGP_TO_OSPF permit 10
   match community FROM_FW_EXTERNO_TO_CORE_01
   match ip address prefix-list DEFAULT
   set tag 6465110
   set metric 250
 # route map que clasifica rutas externas desde firewall
 route-map BGP_TO_OSPF permit 20
   match community FROM_FW_EXTERNO_TO_CORE_01
   set tag 6465111
   set metric 250
 # route map que clasifica rutas externas desde otros origenes
 route-map BGP_TO_OSPF permit 30
   set tag 6465112
   set metric 250
 # route map que clasifica rutas externas desde C9400
 route-map BGP_TO_OSPF permit 40
   match community FROM_C9400_GTDBBVA_01
   set tag 6465113
   
 # para VRF DEFAULT <<>> OSPF_TO_BGP
 
 # elimina el route map para luego reconfigurarlo
 no route-map OSPF_TO_BGP
 #route-map OSPF_TO_BGP deny 5
 #  match tag 64652
 #route-map OSPF_TO_BGP deny 6
 #  match tag 65351
 #route-map OSPF_TO_BGP deny 7
 #  match tag 65352
 #route-map OSPF_TO_BGP deny 8
 #  match tag 64650
 #route-map OSPF_TO_BGP deny 9
 #  match tag 65518
 #route-map OSPF_TO_BGP permit 10
 #  match ip address prefix-list REDES_SUMM_GTD
 #  set community 64651:1 64651:2 additive
 #route-map OSPF_TO_BGP permit 15
 #  set community 64651:1
 
 # route map rutas por defecto generados por ospf de cada site
 route-map OSPF_TO_BGP deny 10
   match tag 653510 653520 646510 646520
 # route map external y el resto desde firewall core 1 cpd
 route-map OSPF_TO_BGP deny 20
   match tag 6535110 6535111 6535112
 # route map external y el resto desde firewall core 2 cpd
 route-map OSPF_TO_BGP deny 30
   match tag 6535210 6535211 6535212
 # route map external y el resto desde firewall core 1 gtd
 route-map OSPF_TO_BGP deny 40
   match tag 6465110 6465111 6465112 6465113
 # route map external y el resto desde firewall core 2 gtd
 route-map OSPF_TO_BGP deny 50
   match tag 6465210 6465211 6465212 6465213
 # route map envia redes aprendidas por ospf a bgp de gtd
 route-map OSPF_TO_BGP permit 60
   match ip address prefix-list REDES_SUMM_GTD
   set community 64651:11
 # route map envia redes aprendidas por ospf a bgp de cpd
 route-map OSPF_TO_BGP permit 70
   set community 64651:12

 # para VRF12 <<>> BGP_TO_OSPF

 # elimina el route map para luego reconfigurarlo
 no route-map BGP_TO_OSPF_VRF12
 #route-map BGP_TO_OSPF_VRF12 permit 10
 #  set tag 64751
 
 # route map que clasifica la ruta por defecto desde firewall
 route-map BGP_TO_OSPF_VRF12 permit 10
   match ip address prefix-list DEFAULT_VRF12
   set tag 6475110
 # route map que clasifica rutas externas desde firewall y otros origenes
 route-map BGP_TO_OSPF_VRF12 permit 20
   set tag 6475111
   
 # para VRF12 <<>> OSPF_TO_BGP
 
 # elimina el route map para luego reconfigurarlo
 no route-map OSPF_TO_BGP_VRF12
 #route-map OSPF_TO_BGP_VRF12 deny 5
 #  match tag 64752
 #route-map OSPF_TO_BGP_VRF12 permit 10
 #  set community 64751:1

 # route map rutas por defecto generados por ospf de cada site
 route-map OSPF_TO_BGP_VRF12 deny 10
   match tag 647510 647520
 # route map external y el resto desde firewall core 1 gtd
 route-map OSPF_TO_BGP_VRF12 deny 20
   match tag 6475110 6475111
 # route map external y el resto desde firewall core 2 gtd
 route-map OSPF_TO_BGP_VRF12 deny 30
   match tag 6475210 6475211
 # route map envia redes aprendidas por ospf a bgp de gtd
 route-map OSPF_TO_BGP_VRF12 permit 40
   set community 64751:11

OBJETIVO [3] estandarizar lo tags de redistribucion OSPF <-> BGP en vrf default en N9KA

 ###
 C9500-GTDBBVA-01 - AS IS
  route-map TO_B2B_C9500-GTDBBVA-02 permit 10
  
  route-map FROM_B2B_C9500-GTDBBVA-02 permit 10
  ------------------------------------------------------------------
  
  ip prefix-list Red_Default seq 10 permit 0.0.0.0/0
  
  ip community-list standard FGT_OFICINAS permit 65000:3
  
  ip prefix-list SDWAN_MONITOR_OFICINA seq 10 permit 119.237.61.1/32
  
  route-map FROM_SDWAN_FORTINET_OFICINA deny 10
   description Denegar Red Default del FORTINET
   match ip address prefix-list Red_Default
  
  route-map FROM_SDWAN_FORTINET_OFICINA permit 20
   match community FGT_OFICINAS
   set local-preference 200
  
  route-map TO_SDWAN_FORTINET_OFICINA permit 5
   match ip address prefix-list SDWAN_MONITOR_OFICINA
   set community 64651:2
  
  route-map TO_SDWAN_FORTINET_OFICINA permit 10
  ------------------------------------------------------------------
  
  ip community-list standard FGT_ATMS permit 65001:3
  
  ip prefix-list SDWAN_MONITOR_ATM seq 10 permit 119.237.61.3/32
  
  route-map FROM_SDWAN_FORTINET_ATM deny 10
   description Denegar Red Default del FORTINET
   match ip address prefix-list Red_Default
  
  route-map FROM_SDWAN_FORTINET_ATM permit 20
   match community FGT_ATMS
   set local-preference 200
  
  route-map TO_SDWAN_FORTINET_ATM permit 5
   match ip address prefix-list SDWAN_MONITOR_ATM
   set community 64651:2
  
  route-map TO_SDWAN_FORTINET_ATM permit 10
  ------------------------------------------------------------------
  
  ip community-list standard TO_CORE_BLOCK permit 64651:1
  ip community-list standard TO_CORE_BLOCK permit 64652:1
  
  route-map TO_N5K-GTDBBVA-01 deny 5
   match community TO_CORE_BLOCK
  
  route-map TO_N5K-GTDBBVA-01 permit 10
  
  route-map FROM_N5K-GTDBBVA-01 permit 10
   set local-preference 200
 ###
 
 C9500-GTDBBVA-01 - TO BE
 
  route-map TO_SDWAN_FORTINET_OFICINA permit 5
   no set community 64651:2
   set community 64526:12
 
  route-map TO_SDWAN_FORTINET_ATM permit 5
   no set community 64651:2
   set community 64526:12
 
  no ip community-list standard TO_CORE_BLOCK permit 64651:1
  no ip community-list standard TO_CORE_BLOCK permit 64652:1
  ip community-list standard TO_CORE_BLOCK permit 64651:11
  ip community-list standard TO_CORE_BLOCK permit 64652:11

OBJETIVO [4] estandarizar lo tags de redistribucion OSPF <-> BGP en vrf default en FW

 Migracion de etiquetas para FW
  64651:1 -> 64651:11
  64652:1 -> 64652:11
  64651:2 -> 64526:12

CORE 2 GTD

OBJETIVO [1] tagear la ruta por defecto de ospf en vrf default y vrf 12

 ip prefix-list DEFAULT seq 5 permit 0.0.0.0/0
 ip prefix-list DEFAULT_VRF12 seq 5 permit 0.0.0.0/0
 
 route-map DEFAULT permit 10
 match ip address prefix-list DEFAULT
 set tag 646520
 set metric 260

 route-map DEFAULT permit 10
 match ip address prefix-list DEFAULT_VRF12
 set tag 647520

 router ospf 100
   default-information originate route-map DEFAULT

 router ospf 200
   vrf VRF12-INTERNET-DC2
     default-information originate route-map DEFAULT_VRF12

OBJETIVO [2] estandarizar lo tags de redistribucion OSPF <-> BGP en vrf default y vrf 12

 # para VRF DEFAULT <<>> BGP_TO_OSPF

 # elimina el route map para luego reconfigurarlo
 no route-map BGP_TO_OSPF
 #route-map BGP_TO_OSPF permit 5
 #  match community FROM_FW_EXTERNO_TO_CORE_02
 #  set tag 64650
 #  set metric 260
 #route-map BGP_TO_OSPF permit 7
 #  match community FROM_C9400_GTDBBVA_02
 #  set tag 65518
 #route-map BGP_TO_OSPF permit 10
 #  set tag 64652
 #  set metric 260
 
 # route map que clasifica la ruta por defecto desde firewall
 route-map BGP_TO_OSPF permit 10
   match community FROM_FW_EXTERNO_TO_CORE_02
   match ip address prefix-list DEFAULT
   set tag 6465210
   set metric 260
 # route map que clasifica rutas externas desde firewall
 route-map BGP_TO_OSPF permit 20
   match community FROM_FW_EXTERNO_TO_CORE_02
   set tag 6465211
   set metric 260
 # route map que clasifica rutas externas desde otros origenes
 route-map BGP_TO_OSPF permit 30
   set tag 6465212
   set metric 260
 # route map que clasifica rutas externas desde C9400
 route-map BGP_TO_OSPF permit 40
   match community FROM_C9400_GTDBBVA_02
   set tag 6465213
 
 # para VRF DEFAULT <<>> OSPF_TO_BGP
 
 # elimina el route map para luego reconfigurarlo
 no route-map OSPF_TO_BGP
 #route-map OSPF_TO_BGP deny 5
 #  match tag 64651
 #route-map OSPF_TO_BGP deny 6
 #  match tag 65351
 #route-map OSPF_TO_BGP deny 7
 #  match tag 65352
 #route-map OSPF_TO_BGP deny 8
 #  match tag 64650
 #route-map OSPF_TO_BGP deny 9
 #  match tag 65518
 #route-map OSPF_TO_BGP permit 10
 #  match ip address prefix-list REDES_SUMM_GTD
 #  set community 64652:1 64652:2 additive
 #route-map OSPF_TO_BGP permit 15
 #  set community 64652:1
    
 # route map rutas por defecto generados por ospf de cada site
 route-map OSPF_TO_BGP deny 10
   match tag 653510 653520 646510 646520
 # route map external y el resto desde firewall core 1 cpd
 route-map OSPF_TO_BGP deny 20
   match tag 6535110 6535111 6535112
 # route map external y el resto desde firewall core 2 cpd
 route-map OSPF_TO_BGP deny 30
   match tag 6535210 6535211 6535212
 # route map external y el resto desde firewall core 1 gtd
 route-map OSPF_TO_BGP deny 40
   match tag 6465110 6465111 6465112 6465113
 # route map external y el resto desde firewall core 2 gtd
 route-map OSPF_TO_BGP deny 50
   match tag 6465210 6465211 6465212 6465213
 # route map envia redes aprendidas por ospf a bgp de gtd
 route-map OSPF_TO_BGP permit 60
   match ip address prefix-list REDES_SUMM_GTD
   set community 64652:11
 # route map envia redes aprendidas por ospf a bgp de cpd
 route-map OSPF_TO_BGP permit 70
   set community 64652:12

 # para VRF12 <<>> BGP_TO_OSPF

 # elimina el route map para luego reconfigurarlo
 no route-map BGP_TO_OSPF_VRF12
 #route-map BGP_TO_OSPF_VRF12 permit 10
 #  set tag 64752
 
 # route map que clasifica la ruta por defecto desde firewall
 route-map BGP_TO_OSPF_VRF12 permit 10
   match ip address prefix-list DEFAULT_VRF12
   set tag 6475210
 # route map que clasifica rutas externas desde firewall y otros origenes
 route-map BGP_TO_OSPF_VRF12 permit 20
   set tag 6475211
   
 # para VRF12 <<>> OSPF_TO_BGP
 
 # elimina el route map para luego reconfigurarlo
 no route-map OSPF_TO_BGP_VRF12
 #route-map OSPF_TO_BGP_VRF12 deny 5
 #  match tag 64752
 #route-map OSPF_TO_BGP_VRF12 permit 10
 #  set community 64751:1

 # route map rutas por defecto generados por ospf de cada site
 route-map OSPF_TO_BGP_VRF12 deny 10
   match tag 647510 647520
 # route map external y el resto desde firewall core 1 gtd
 route-map OSPF_TO_BGP_VRF12 deny 20
   match tag 6475110 6475111
 # route map external y el resto desde firewall core 2 gtd
 route-map OSPF_TO_BGP_VRF12 deny 30
   match tag 6475210 6475211
 # route map envia redes aprendidas por ospf a bgp de gtd
 route-map OSPF_TO_BGP_VRF12 permit 40
   set community 64752:11

OBJETIVO [3] estandarizar lo tags de redistribucion OSPF <-> BGP en vrf default en N9KB

 ###
 C9500-GTDBBVA-02 - AS IS
  route-map FROM_B2B_C9500-GTDBBVA-01 permit 10
  
  route-map TO_B2B_C9500-GTDBBVA-01 permit 10
  ------------------------------------------------------------------
  
  ip prefix-list Red_Default seq 10 permit 0.0.0.0/0
  
  ip community-list standard FGT_OFICINAS permit 65000:4
  
  ip prefix-list SDWAN_MONITOR_OFICINA seq 10 permit 119.237.61.2/32
  
  route-map FROM_SDWAN_FORTINET_OFICINA deny 10
   description Denegar Red Default del FORTINET
   match ip address prefix-list Red_Default
  
  route-map FROM_SDWAN_FORTINET_OFICINA permit 20
   match community FGT_OFICINAS
   set local-preference 100
  
  route-map TO_SDWAN_FORTINET_OFICINA permit 5
   match ip address prefix-list SDWAN_MONITOR_OFICINA
   set community 64652:2
  
  route-map TO_SDWAN_FORTINET_OFICINA permit 10
  ------------------------------------------------------------------
  
  ip community-list standard FGT_ATMS permit 65001:4
  
  ip prefix-list SDWAN_MONITOR_ATM seq 10 permit 119.237.61.4/32
  
  route-map FROM_SDWAN_FORTINET_ATM deny 10
   description Denegar Red Default del FORTINET
   match ip address prefix-list Red_Default
  
  route-map FROM_SDWAN_FORTINET_ATM permit 20
   match community FGT_ATMS
   set local-preference 100
  
  route-map TO_SDWAN_FORTINET_ATM permit 5
   match ip address prefix-list SDWAN_MONITOR_ATM
   set community 64652:2
  
  route-map TO_SDWAN_FORTINET_ATM permit 10
  ------------------------------------------------------------------
  
  ip community-list standard TO_CORE_BLOCK permit 64651:1
  ip community-list standard TO_CORE_BLOCK permit 64652:1
  
  route-map TO_N5K-GTDBBVA-01 deny 5
   match community TO_CORE_BLOCK
  
  route-map TO_N5K-GTDBBVA-02 permit 10
  
  route-map FROM_N5K-GTDBBVA-02 permit 10
 ###
 
 C9500-GTDBBVA-02 - TO BE
 
  route-map TO_SDWAN_FORTINET_OFICINA permit 5
   no set community 64652:2
   set community 64526:13
 
  route-map TO_SDWAN_FORTINET_ATM permit 5
   no set community 64652:2
   set community 64526:13
 
  no ip community-list standard TO_CORE_BLOCK permit 64651:1
  no ip community-list standard TO_CORE_BLOCK permit 64652:1
  ip community-list standard TO_CORE_BLOCK permit 64651:11
  ip community-list standard TO_CORE_BLOCK permit 64652:11

OBJETIVO [4] estandarizar lo tags de redistribucion OSPF <-> BGP en vrf default en FW

 Migracion de etiquetas para FW
  64651:1 -> 64651:11
  64652:1 -> 64652:11
  64652:2 -> 64526:13

FASE 2 Configuracion eBGP entre COREs de ambos sites

OBJETIVO [1.1] reconfiguracion de route-maps entre cores site cpd

 # B2B DEFAULT

route-map FROM_B2B_N9K_CORE_2 permit 10
route-map TO_B2B_N9K_CORE_2 deny 10
  match community TO_CORE_2
route-map TO_B2B_N9K_CORE_2 permit 20

 # B2B VRF11

route-map FROM_B2B_N9K_CORE_2_VRF11 permit 10
route-map TO_B2B_N9K_CORE_2_VRF11 deny 10
  match community TO_CORE_2_VRF11
route-map TO_B2B_N9K_CORE_2_VRF11 permit 20


OBJETIVO [1.2] reconfiguracion de route-maps entre cores site gtd

OBJETIVO [2.1] creacion de route-map entre cores del site cpd para conexions dci
OBJETIVO [2.2] creacion de route-map entre cores del site gtd para conexions dci

OBJETIVO [3.1] configuracion peering ebgp en cores 1-4 (shutdown)

OBJETIVO [4.1] depuracion ospf en interfaces dci entre cores 1 y 3 y encendido de peering ebgp
OBJETIVO [4.2] validación de enrutamiento
OBJETIVO [4.3] depuracion ospf en interfaces dci entre cores 2 y 4 y encendido de peering ebgp
OBJETIVO [4.4] validación de enrutamiento

FASE 3 Configuracion eBGP entre COREs y Miraflores

OBJETIVO [1.1] creacion de route-map hacia fusiones 1 y 2 en cores 1-4

CORE 1 CPD

CORE 2 CPD

CORE 1 GTD

CORE 2 GTD

OBJETIVO [1.2] configuracion peering ebgp en cores 1-4 con fusion 1 y 2
OBJETIVO [1.3] depuracion ospf en interfaces hacia sw-miraflores en cores 1-4

OBJETIVO [2.1] migracion de config de Twe 23->19 y 24->20 en fusiones 1 y 2
OBJETIVO [2.2] depuracion de enlaces Twe 23 y 24 en fusiones 1 y 2
OBJETIVO [2.3] movimiento de cables de Twe 23->19 y 24->20 en fusiones 1 y 2

OBJETIVO [3.1] desconexion de  uplinks en Twe 1/1/1 y 1/1/2 en  sw miraflores
OBJETIVO [3.2] conexion de enlaces uplinks Twe 24 (Po-L3) en fusiones 1 y 2 - Po-L3(Twe 23 y 24)
OBJETIVO [3.3] conexion de enlaces Twe 21 y 22 entre fusiones 1 y 2

OBJETIVO [4.1] configuracion de Po-L3(Twe 23 y 24) para enlaces hacia cores
OBJETIVO [4.2] configuracion de Po-L3(Twe 21 y 22) para enlaces entre fusiones 1 y 2
OBJETIVO [4.3] creacion de route-map hacia core cdp 1 , 2 y fusion 2 en fusion 1
OBJETIVO [4.4] creacion de route-map hacia core gtd 1 , 2 y fusion 1 en fusion 2
OBJETIVO [4.5] configuracion peering ibgp en fusiones 1 y 2
OBJETIVO [4.6] configuracion peering ebgp en fusiones 1 y 2 con cores 1-4 (shutdown)

OBJETIVO [5.1] encendido de vecino gtd core 1 en fusion 2
OBJETIVO [5.2] validación de enrutamiento
OBJETIVO [5.3] encendido de vecino gtd core 2 en fusion 2
OBJETIVO [5.4] validación de enrutamiento
OBJETIVO [5.5] encendido de vecino cpd core 1 en fusion 1
OBJETIVO [5.6] validación de enrutamiento
OBJETIVO [5.7] encendido de vecino cpd core 2 en fusion 1
OBJETIVO [5.8] validación de enrutamiento

OBJETIVO [6.1] depuracion de configuracion ospf de uplinks/proceso en sw miraflores
OBJETIVO [6.2] depuracion de svis en sw miraflores {50, 631, 632, 634, 635, 674, 677, 678, 680, 681, 682, 683, 684, 685, 686, 687, 688, 689, 900}
OBJETIVO [6.3] configuracion de svis en modo hsrp en fusiones
OBJETIVO [6.4] creacion de rutas estaticas hacia el firewall en fusion 1 y 2
OBJETIVO [6.5] creacion de rutas estaticas hacia a la vip de hsrp de fusion 1 y 2 en firewall

OBJETIVO [7.1] prueba de failover enlace principal fusion 2
OBJETIVO [7.2] validación de enrutamiento
OBJETIVO [7.3] prueba de failover enlace secundario fusion 2
OBJETIVO [7.4] validación de enrutamiento
OBJETIVO [7.5] prueba de failover enlace principal fusion 1
OBJETIVO [7.6] validación de enrutamiento
OBJETIVO [7.5] prueba de switchback enlace principal fusion 1
OBJETIVO [7.6] validación de enrutamiento
OBJETIVO [7.7] prueba de switchback enlace secundario fusion 2
OBJETIVO [7.8] validación de enrutamiento
OBJETIVO [7.1] prueba de switchback enlace principal fusion 2
OBJETIVO [7.2] validación de enrutamiento

test



