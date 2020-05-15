*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_pypl_parser DEFINITION
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      TT_pypl TYPE STANDARD TABLE OF yhska_14_prog.
    METHODS:
      get_HTML
        RETURNING VALUE(ex_html) TYPE string_table,
      filter_pypl
        IMPORTING im_html TYPE string_table
        EXPORTING ex_pypl TYPE TT_pypl.

  PROTECTED SECTION.
  PRIVATE SECTION.
*    TYPES:
*               TT_pypl TYPE STANDARD TABLE OF yhska_14_prog.
*    DATA:
*        ls_html TYPE string_table.
ENDCLASS.


CLASS lcl_pypl_parser IMPLEMENTATION.

*  METHOD constructor.
*  ENDMETHOD.

  METHOD get_HTML.
    DATA(lv_url) = |http://pypl.github.io/PYPL.html|.
    TRY.
        DATA(lo_destination)     = cl_http_destination_provider=>create_by_url( lv_url ).
        DATA(lo_http)            = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        DATA(lo_request)         = lo_http->get_http_request( ).
        DATA(lo_reponse)         = lo_http->execute( i_method = if_web_http_client=>get ).
        DATA(lo_response_text)   = lo_reponse->get_text(  ).
        SPLIT lo_response_text AT cl_abap_char_utilities=>cr_lf INTO TABLE ex_html.
      CATCH cx_root INTO DATA(lx_root).
    ENDTRY.
  ENDMETHOD.

  METHOD filter_pypl.
    DATA(lt_html) = im_html.
    LOOP AT lt_html INTO DATA(lv_nohtml) WHERE table_line CS 'begin section ALL'.

      REPLACE ALL OCCURRENCES OF REGEX '<[a-zA-Z\/][^>]*>' IN lv_nohtml WITH '_'.
      REPLACE ALL OCCURRENCES OF REGEX '%' IN lv_nohtml WITH ''.
      REPLACE ALL OCCURRENCES OF REGEX '\s' IN lv_nohtml WITH ''.
*        REPLACE ALL OCCURRENCES OF REGEX '\n' IN result WITH ''

      SPLIT lv_nohtml AT '\' INTO TABLE DATA(lt_list).
      DELETE lt_list INDEX 1.
      DELETE lt_list WHERE table_line CS 'endsectionALL'.

*PYPL: Rank  Language    Share   Trend

      LOOP AT lt_list INTO DATA(lv_linetable).
        DATA(lo_distributer) = cl_abap_matcher=>create( pattern     = '_+([^_]+)_+([^_]+)_+([^_]+)_+([^_]+)_+.*'
                                             ignore_case = abap_true
                                             text = lv_linetable
                                             ).
        IF abap_true = lo_distributer->match( ).
        DATA(lv_uppercase_name) = lo_distributer->get_submatch( 2 ).
        TRANSLATE lv_uppercase_name TO UPPER CASE.

          DATA(ls_filler) = VALUE yhska_14_prog( name = lv_uppercase_name
                                               shares = lo_distributer->get_submatch( 3 )
                                               trends = lo_distributer->get_submatch( 4 )
                                               ).
          APPEND ls_filler TO ex_pypl.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT ex_pypl INTO DATA(ls_cadder) WHERE name = 'C/C++'.
    ENDLOOP.

*    MODIFY ex_pypl FROM .
*        UPDATE FIELDS ( name )
*        WITH value #( for 'C/C++' in name(
*                         name = 'C' ) ) .

    READ TABLE ex_pypl WITH KEY name ='C/C++' ASSIGNING FIELD-SYMBOL(<ls_language>).
    IF sy-subrc EQ 0.
      <ls_language>-name = 'C'.
    ENDIF.

    APPEND ls_cadder TO ex_pypl.
    READ TABLE ex_pypl WITH KEY name ='C/C++' ASSIGNING <ls_language>.
    IF sy-subrc EQ 0.
      <ls_language>-name = 'C++'.
    ENDIF.

    SORT ex_pypl BY shares DESCENDING.

  ENDMETHOD.
ENDCLASS.
