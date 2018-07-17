REPORT zbc400_operator_new.

TYPES: gt_tab     TYPE STANDARD TABLE OF i WITH DEFAULT KEY,
       gt_tab_sor TYPE SORTED TABLE OF i WITH UNIQUE KEY table_line,
       BEGIN OF gty_sorted_tab,
         num TYPE i,
       END OF gty_sorted_tab,
       gtt_sorted_tab TYPE SORTED TABLE OF gty_sorted_tab WITH UNIQUE KEY num,
       BEGIN OF gty_alv_data,
         kunnr   TYPE kunnr,
         name1   TYPE name1,
         ort01   TYPE ort01,
         land1   TYPE land1,
         t_color TYPE lvc_t_scol,
       END OF gty_alv_data,
       gtt_alv_data TYPE STANDARD TABLE OF gty_alv_data WITH DEFAULT KEY.

DATA: go_data TYPE REF TO data.

FIELD-SYMBOLS: <gfs>  TYPE gt_tab,
               <gfs2> TYPE gtt_sorted_tab,
               <gfs3> TYPE gtt_alv_data.


SELECT * FROM sflight INTO TABLE @DATA(gt_sflight) UP TO 10 ROWS.

CREATE DATA go_data TYPE gt_tab.
ASSIGN go_data->* TO <gfs>.
APPEND: 100 TO <gfs>,
        200 TO <gfs>,
        0 TO <gfs>.

cl_demo_output=>display( <gfs> ).
DATA: go_data2 TYPE REF TO data,
      go_data3 TYPE REF TO data,
      go_data4 TYPE REF TO data,
      go_data5 TYPE REF TO data.

go_data2 = NEW gt_tab( ( 100 ) ( ) ( 200 ) ).
go_data3 = NEW gt_tab_sor( (  100 ) ( ) ( 200 ) ).
go_data4 = NEW gtt_sorted_tab( ( num = 100 ) ( num = 0 ) ( num = 200 ) ).
ASSIGN go_data4->* TO <gfs2>.
cl_demo_output=>display( <gfs2> ).


go_data5 = NEW gtt_alv_data( ( kunnr = '0001' name1 = 'Olyvia' ort01 = 'Comment' land1 = 'New-York'
    t_color = VALUE #( ( fname = 'KUNNR' color-col = col_negative color-int = 0 color-inv = 0 )
                       ( fname = 'NAME1' color-col = col_positive color-int = 0 color-inv = 0 )
                        ) ) ).

ASSIGN go_data5->* TO <gfs3>.
cl_demo_output=>display( <gfs3> ).