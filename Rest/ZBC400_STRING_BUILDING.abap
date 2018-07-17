REPORT zbc400_string_building.

DATA: gv_var1 TYPE char30,
      gv_var2 TYPE char30,
      gv_var3 TYPE char30.

DATA: gv_result TYPE string,
      gv_char   TYPE char100.

*Using &&
gv_var1 = 'building'.
gv_var2 =  'string'.
gv_var3 = 'one'.
gv_result = gv_var1 && ` ` && gv_var2 && ` ` && gv_var3.
WRITE: /(15) 'Usando &&', gv_result.

*Using string templates
*gv_result = | { gv_var1 } | & | { gv_var2 } | & | { gv_var3 }|.
gv_result = | { gv_var1 },{ gv_var2 },{ gv_var3 }|.
WRITE: /(15) 'Usando template', gv_result.

*Using concatenate
CONCATENATE gv_var1 gv_var2 gv_var3 INTO gv_result SEPARATED BY space.
WRITE: /(20) 'Usando concatenação', gv_result.

*Using type
TYPES: BEGIN OF gty_string,
       var1 TYPE char30,
       var2 TYPE char30,
       var3 TYPE char30,
       END OF gty_string.
 DATA: gs_result TYPE gty_string.
 gs_result-var1 = gv_var1.
 gs_result-var2 = gv_var2.
 gs_result-var3 = gv_var3.
 CONDENSE gs_result.
 gv_result = gs_result.
 WRITE: /(15) 'Usando tipo', gv_result.