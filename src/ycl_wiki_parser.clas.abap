CLASS ycl_wiki_parser DEFINITION
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



CLASS ycl_wiki_parser IMPLEMENTATION.
  METHOD get_table.
    DATA(lo_html_parser) = NEW lcl_wiki_parser( ).
    DATA(lv_html) = lo_html_parser->get_html( EXPORTING im_url = 'https://en.wikipedia.org/wiki/Timeline_of_programming_languages').
    lo_html_parser->filter_wiki( EXPORTING im_html = lv_html
                                 IMPORTING ex_wiki = ls_insertTable ).
    ex_insertTable = ls_insertTable.
  ENDMETHOD.
ENDCLASS.
