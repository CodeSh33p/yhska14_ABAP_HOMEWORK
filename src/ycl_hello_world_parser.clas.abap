CLASS ycl_hello_world_parser DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun.
    TYPES:
      TT_insertTable TYPE STANDARD TABLE OF yhska_14_prog.
    DATA:
      ls_insertTable TYPE STANDARD TABLE OF yhska_14_prog.
    METHODS:
      get_table
        EXPORTING ex_insertTable TYPE TT_insertTable.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_hello_world_parser IMPLEMENTATION.
  METHOD get_table.
    DATA(lv_html_parser) = NEW lcl_hello_world_parser( ).
    DATA(lv_html) = lv_html_parser->get_html( ).
    lv_html_parser->filter_hello_world( EXPORTING im_html = lv_html
                                 IMPORTING ex_hello_world = ls_insertTable ).
    ex_insertTable = ls_insertTable.
  ENDMETHOD.
ENDCLASS.
