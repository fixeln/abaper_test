    CLASS lcl_editable_salv DEFINITION INHERITING FROM cl_salv_model.
      PUBLIC SECTION.
        DATA: go_controller TYPE REF TO cl_salv_controller_model,
              go_adapter    TYPE REF TO cl_salv_adapter.

        METHODS: grabe_model IMPORTING imo_model TYPE REF TO cl_salv_model,
          grabe_controller,
          grabe_adapter.
      PRIVATE SECTION.
        DATA: lo_model TYPE REF TO cl_salv_model.
    ENDCLASS.

    CLASS lcl_event_handler DEFINITION.
      PUBLIC SECTION.
        METHODS: on_user_event FOR EVENT added_function OF cl_salv_events IMPORTING e_salv_function.
    ENDCLASS.

    CLASS lcl_report DEFINITION .
      PUBLIC SECTION.
        TYPES: tty_sflights TYPE STANDARD TABLE OF sflights.
        DATA: gt_sflights   TYPE tty_sflights,
              go_salv       TYPE REF TO cl_salv_table,
              go_salv_model TYPE REF TO lcl_editable_salv.
        METHODS: get_data,
          generate_output,
          set_top_of_page CHANGING go_salv TYPE REF TO cl_salv_table.
    ENDCLASS.

    CLASS lcl_editable_salv IMPLEMENTATION.
      METHOD grabe_model.
        lo_model = imo_model.
      ENDMETHOD.

      METHOD grabe_controller.
        go_controller = lo_model->r_controller.
      ENDMETHOD.

      METHOD grabe_adapter.
        go_adapter ?= lo_model->r_controller->r_adapter.
      ENDMETHOD.
    ENDCLASS.

    CLASS lcl_event_handler IMPLEMENTATION.
      METHOD on_user_event.
        DATA: lo_grid      TYPE REF TO cl_gui_alv_grid,
              lo_full_adap TYPE REF TO cl_salv_fullscreen_adapter,
              ls_layout    TYPE lvc_s_layo,
              lt_layout    TYPE lvc_t_fcat,
              lo_report    TYPE REF TO lcl_report.
        FIELD-SYMBOLS: <lfs_fieldcat> TYPE lvc_s_fcat.
        CASE e_salv_function.
          WHEN 'MYFUNCTION'.
            CREATE OBJECT lo_report.
            CALL METHOD lo_report->go_salv_model->grabe_controller.
            CALL METHOD lo_report->go_salv_model->grabe_adapter.
            lo_full_adap ?= lo_report->go_salv_model->go_adapter.
            lo_grid = lo_full_adap->get_grid( ).
            IF lo_grid IS BOUND.
              lo_grid->get_frontend_fieldcatalog( IMPORTING et_fieldcatalog = lt_layout ).
              LOOP AT lt_layout ASSIGNING <lfs_fieldcat>.
                CASE <lfs_fieldcat>-fieldname.
                  WHEN 'SEATSMAX'.
                    <lfs_fieldcat>-edit = 'X'.
                ENDCASE.
              ENDLOOP.
              lo_grid->set_frontend_fieldcatalog( EXPORTING it_fieldcatalog = lt_layout ).
              CALL METHOD lo_grid->refresh_table_display( ).
            ENDIF.
        ENDCASE.
      ENDMETHOD.
    ENDCLASS.

    CLASS lcl_report IMPLEMENTATION.
      METHOD get_data.
        SELECT * FROM sflights INTO TABLE me->gt_sflights UP TO 30 ROWS.
      ENDMETHOD.

      METHOD set_top_of_page.
        DATA: lo_header  TYPE REF TO cl_salv_form_layout_grid,
              lo_h_label TYPE REF TO cl_salv_form_label,
              lo_h_flow  TYPE REF TO cl_salv_form_layout_flow.

        CREATE OBJECT lo_header.

        lo_h_label = lo_header->create_label( EXPORTING row = 1
                                                        column = 5 ).
        lo_h_label->set_text( 'Titulo em Bold...' ).

        lo_h_flow = lo_header->create_flow( column = 1
                                            row = 2 ).
        lo_h_flow->create_text( text = 'Texto flowgic' ).
        lo_h_flow = lo_header->create_flow( row = 3
                                            column = 1 ).
        lo_h_flow->create_text( text = 'Numero de entradas na saida' ).
        lo_h_flow = lo_header->create_flow( column = 2
                                            row = 3 ).
        lo_h_flow->create_text( text = 20 ).
        go_salv->set_top_of_list( lo_header ).
        go_salv->set_top_of_list_print( lo_header ).
      ENDMETHOD.

      METHOD generate_output.
        TRY.
            cl_salv_table=>factory( EXPORTING list_display = abap_false
                                    IMPORTING r_salv_table = go_salv
                                    CHANGING t_table = gt_sflights ).
          CATCH cx_salv_msg.
        ENDTRY.
        go_salv->set_screen_status( EXPORTING pfstatus = 'SALV_STANDARD'
                                              report = 'SALV_DEMO_TABLE_EVENTS'
                                              set_functions = go_salv->c_functions_all ).

        DATA: lo_events   TYPE REF TO cl_salv_events_table,
              lo_events_h TYPE REF TO lcl_event_handler.
        lo_events = go_salv->get_event( ).
        CREATE OBJECT lo_events_h.
        SET HANDLER lo_events_h->on_user_event FOR lo_events.
        DATA: lo_alv_mod TYPE REF TO cl_salv_model.
        lo_alv_mod ?= go_salv.
        CREATE OBJECT go_salv_model.
        CALL METHOD go_salv_model->grabe_model( imo_model = lo_alv_mod ).
        CALL METHOD me->set_top_of_page
          CHANGING
            go_salv = go_salv.
        go_salv->display( ).
      ENDMETHOD.
    ENDCLASS.