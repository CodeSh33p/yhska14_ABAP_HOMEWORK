*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_tiobe_parser DEFINITION
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      TT_tiobe TYPE STANDARD TABLE OF yhska_14_prog.
    METHODS:
      get_HTML
        RETURNING VALUE(ex_html) TYPE string_table,
      filter_tiobe
        IMPORTING im_html  TYPE string_table
        EXPORTING ex_tiobe TYPE TT_tiobe.
  PROTECTED SECTION.
  PRIVATE SECTION.
*    TYPES:
*               TT_tiobe TYPE STANDARD TABLE OF yhska_14_prog.
*    DATA:
*        ls_html TYPE string_table.
ENDCLASS.


CLASS lcl_tiobe_parser IMPLEMENTATION.

*  METHOD constructor.
*  ENDMETHOD.

  METHOD get_HTML.
    DATA(lv_url) = |https://www.tiobe.com/tiobe-index/|.
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

  METHOD filter_tiobe.
    DATA(lt_html) = im_html.

*           Table 1 Loop
    LOOP AT lt_html INTO DATA(lv_nohtml) WHERE table_line CS '<tr><td>1</td><td>'.

      REPLACE ALL OCCURRENCES OF REGEX '<[a-zA-Z\/][^>]*>' IN lv_nohtml WITH '_'.
      REPLACE ALL OCCURRENCES OF REGEX '%' IN lv_nohtml WITH ''.
*      REPLACE ALL OCCURRENCES OF REGEX '(_)+' IN lv_nohtml WITH '_'.
      REPLACE ALL OCCURRENCES OF REGEX '_[0-9]+__[0-9]+_' IN lv_nohtml WITH '?'.


      SPLIT lv_nohtml AT '?' INTO TABLE DATA(lt_list).

      DELETE lt_list INDEX 1.

      LOOP AT lt_list INTO DATA(lv_linetable).
        DATA(lo_distributer) = cl_abap_matcher=>create( pattern     = '_+([^_]+)_+([^_]+)_+([^_]+)_+.*'
                                             ignore_case = abap_true
                                             text = lv_linetable
                                             ).
        IF abap_true = lo_distributer->match( ).
        DATA(lv_uppercase_name) = lo_distributer->get_submatch( 1 ).
        TRANSLATE lv_uppercase_name TO UPPER CASE.

          DATA(ls_filler) = VALUE yhska_14_prog( name = lv_uppercase_name
                                                 rating = lo_distributer->get_submatch( 2 )
                                                 change = lo_distributer->get_submatch( 3 )
                                               ).
          APPEND ls_filler TO ex_tiobe.
        ENDIF.
      ENDLOOP.

*                Table 2 Loop
      LOOP AT lt_html INTO lv_nohtml WHERE table_line CS '<tr><td>21</td><td>'.

        REPLACE ALL OCCURRENCES OF REGEX '<[a-zA-Z\/][^>]*>' IN lv_nohtml WITH '_'.
        REPLACE ALL OCCURRENCES OF REGEX '%' IN lv_nohtml WITH ''.
        REPLACE ALL OCCURRENCES OF REGEX '_[0-9]+__' IN lv_nohtml WITH '?'.

        SPLIT lv_nohtml AT '?' INTO TABLE lt_list.

        DELETE lt_list INDEX 1.

        LOOP AT lt_list INTO lv_linetable.
          lo_distributer = cl_abap_matcher=>create( pattern     = '([^_]+)_+([^_]+)_+.*'
                                               ignore_case = abap_true
                                               text = lv_linetable
                                               ).
          IF abap_true = lo_distributer->match( ).
            ls_filler = VALUE yhska_14_prog( name = lo_distributer->get_submatch( 1 )
                                              rating = lo_distributer->get_submatch( 2 )
                                            ).
            APPEND ls_filler TO ex_tiobe.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
