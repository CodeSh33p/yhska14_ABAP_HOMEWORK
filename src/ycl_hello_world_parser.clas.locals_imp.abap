*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_hello_world_parser DEFINITION
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      TT_hello_world TYPE STANDARD TABLE OF yhska_14_prog.
    METHODS:
      get_HTML
        RETURNING VALUE(ex_html) TYPE string,
      filter_hello_world
        IMPORTING im_html        TYPE string
        EXPORTING ex_hello_world TYPE TT_hello_world.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS lcl_hello_world_parser IMPLEMENTATION.

*  METHOD constructor.
*  ENDMETHOD.

  METHOD get_HTML.
    DATA(lv_url) = |http://helloworldcollection.de/|.
    TRY.
        DATA(lo_destination)     = cl_http_destination_provider=>create_by_url( lv_url ).
        DATA(lo_http)            = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        DATA(lo_request)         = lo_http->get_http_request( ).
        DATA(lo_reponse)         = lo_http->execute( i_method = if_web_http_client=>get ).
        DATA(lo_response_text)   = lo_reponse->get_text(  ).
        ex_html = lo_response_text.
      CATCH cx_root INTO DATA(lx_root).
    ENDTRY.
  ENDMETHOD.

  METHOD filter_hello_world.
    DATA(lv_html) = im_html.
    DATA: lt_languages   TYPE STANDARD TABLE OF string,
          lv_hello_world TYPE string,
          lv_language    TYPE string,
          lv_head        TYPE string,
          lv_tail        TYPE string.

    SPLIT lv_html AT '<h2>' INTO TABLE lt_languages.
*       remove head
    DELETE lt_languages INDEX 1.
    DELETE lt_languages INDEX 1.

    LOOP AT lt_languages INTO lv_language.
*         cut off at </pre>
      SPLIT lv_language AT '</pre>' INTO lv_language lv_tail.

      SPLIT lv_language AT '</h2>' INTO lv_language lv_hello_world.

      SPLIT lv_hello_world AT '<pre>' INTO lv_head lv_hello_world.
      SPLIT lv_hello_world AT |\n| INTO lv_head lv_hello_world.
      TRANSLATE lv_language TO UPPER CASE.
      IF lv_language NE 'HUMAN'.
        DATA(ls_filler) = VALUE yhska_14_prog( name = lv_language
                                               helloworld = lv_hello_world
                                             ).
        APPEND ls_filler TO ex_hello_world.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
