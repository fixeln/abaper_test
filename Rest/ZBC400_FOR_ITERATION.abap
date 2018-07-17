REPORT zbc400_for_iteration.

TYPES: BEGIN OF gty_customer,
         customer TYPE char10,
         name     TYPE char30,
         city     TYPE char30,
         route    TYPE char10,
       END OF gty_customer,
       BEGIN OF gty_route_confi,
         c_route TYPE char10,
         c_type  TYPE char10,
         c_value TYPE char40,
       END OF gty_route_confi,
       BEGIN OF gty_routes,
         c_route TYPE char10,
         name    TYPE char40,
       END OF gty_routes,
       BEGIN OF gty_routes_max,
         route TYPE char10,
         name  TYPE char40,
         value TYPE char40,
       END OF gty_routes_max,
       BEGIN OF gty_routes_cust,
         route    TYPE char10,
         name     TYPE char40,
         customer TYPE char10,
       END OF gty_routes_cust.

TYPES: gtt_city TYPE STANDARD TABLE OF gty_customer WITH EMPTY KEY.
TYPES: gtt_route_confi TYPE SORTED TABLE OF gty_route_confi WITH UNIQUE KEY c_route c_type,
       gtt_routes      TYPE SORTED TABLE OF gty_routes WITH UNIQUE KEY c_route,
       gtt_routes_max  TYPE STANDARD TABLE OF gty_routes_max WITH DEFAULT KEY,
       gtt_routes_cust TYPE STANDARD TABLE OF gty_routes_cust WITH DEFAULT KEY.

DATA: gt_customer TYPE SORTED TABLE OF gty_customer WITH UNIQUE KEY customer.

gt_customer = VALUE #( ( customer = 'C0001' name = 'Name Customer 1' city = 'New-York' route = 'R0001' )
                       ( customer = 'C0002' name = 'Name Customer 2' city = 'London' route = 'R0002')
                       ( customer = 'C0003' name = 'Name Customer 3' city = 'Lisbon' route = 'R0003') ).

DATA(gt_city) = VALUE gtt_city( FOR
gs_customer IN gt_customer WHERE ( route = 'R0002' )
( customer = gs_customer-customer
  name = gs_customer-name
  city = gs_customer-city
  route = gs_customer-route ) ).

DATA(gt_route_confi) = VALUE gtt_route_confi( ( c_route = 'R0001' c_type = 'RTYPE' c_value = 'DSD' )
                                               ( c_route = 'R0001' c_type = 'MAX' c_value =  '30' )
                                               ( c_route = 'R0002' c_type = 'RTYPE' c_value = 'ACG' ) ).
DATA(gt_routes) = VALUE gtt_routes( ( c_route = 'R0001' name = 'Route 1' )
                                    ( c_route = 'R0002' name = 'Route 2' )
                                    ( c_route = 'R0003' name = 'Route 3') ) .

TYPES: gtt_names TYPE STANDARD TABLE OF char40 WITH EMPTY KEY.

DATA(gt_route_name) = VALUE gtt_names( FOR gs_customer IN gt_customer
                               FOR gs_route IN gt_routes WHERE ( c_route = gs_customer-route )
                               ( gs_route-name ) ).
DATA(gt_route_max) = VALUE gtt_routes_max( FOR gs_customer IN gt_customer
                                           FOR gs_route IN gt_routes WHERE ( c_route = gs_customer-route )
                                           FOR gs_route_confi IN gt_route_confi WHERE ( c_route = gs_customer-route
                                                                                 AND c_type = 'MAX' )
                                           ( route = gs_customer-route
                                             name = gs_customer-name
                                            value = gs_route_confi-c_value ) ).
DATA(gt_routes_cust) = VALUE gtt_routes_cust( FOR gs_customer IN gt_customer INDEX INTO cust_index
                                              LET lv_name = gt_routes[ c_route = gt_customer[ cust_index ]-route ]-name
                                                  lv_route = gt_routes[ 1 ]-c_route
                                                  IN name = lv_name
                                                     route = lv_route
                                                     ( customer = gs_customer-customer ) ).
cl_demo_output=>display( gt_routes_cust ).