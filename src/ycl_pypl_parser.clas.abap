*"* Source File for PYPL Parser
CLASS ycl_pypl_parser DEFINITION
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



CLASS ycl_pypl_parser IMPLEMENTATION.

  METHOD get_table.

    DATA(lv_html_parser) = NEW lcl_pypl_parser( ).
    DATA(lt_html) = lv_html_parser->get_html( ).
    lv_html_parser->filter_pypl( EXPORTING im_html = lt_html
                                 IMPORTING ex_pypl = ls_insertTable ).
    ex_insertTable = ls_insertTable.
*    out->write( ls_insertTable ).

  ENDMETHOD.

ENDCLASS.


