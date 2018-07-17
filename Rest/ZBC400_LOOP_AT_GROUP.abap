REPORT zbc400_loop_group.


TYPES: BEGIN OF gty_customer,
         customer TYPE char10,
         name     TYPE char30,
         city     TYPE char30,
         route    TYPE char10,
       END OF gty_customer.

TYPES: gtt_customers TYPE SORTED TABLE OF gty_customer WITH UNIQUE KEY customer.

TYPES: ggt_citys TYPE STANDARD TABLE OF char30 WITH EMPTY KEY.

DATA(gt_customers) = VALUE gtt_customers( ( customer = 'c0001' name = 'Test customer 1' city = 'NY' route = 'r0001' )
                                       (  customer = 'c0002' name = 'Test customer 2' city = 'LA' route = 'r0002' )
                                       (  customer = 'c0003' name = 'Test customer 3' city = 'LA' route = 'r0002' )
                                       (  customer = 'c0004' name = 'Test customer 4' city = 'LIS' route = 'r0004') ).
LOOP AT gt_customers INTO DATA(gl_customer) GROUP BY ( route = gl_customer-route ) ASCENDING WITHOUT MEMBERS REFERENCE INTO DATA(lv_route).
  WRITE: / lv_route->route.
ENDLOOP.
CLEAR gl_customer.
LOOP AT gt_customers INTO gl_customer GROUP BY ( route = gl_customer-route
                                                      size = GROUP SIZE
                                                      index = GROUP INDEX ) ASCENDING REFERENCE INTO DATA(lv_route2).
  WRITE: / 'Group', lv_route2->size, 'route', lv_route2->route.

  DATA(lt_members) = VALUE gtt_customers( ).
  LOOP AT GROUP lv_route2 ASSIGNING FIELD-SYMBOL(<lfs_route>).
    lt_members = VALUE #( BASE lt_members ( <lfs_route> ) ).
  ENDLOOP.

  LOOP AT lt_members INTO DATA(ls_member).
    WRITE: AT /(5) ls_member-customer, ls_member-name, ls_member-city.
  ENDLOOP.
  WRITE: AT /(5) 'Group size ', lv_route2->size.
  SKIP 2.
ENDLOOP.