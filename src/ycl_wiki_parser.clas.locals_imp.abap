*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_wiki_parser DEFINITION
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      TT_wiki TYPE STANDARD TABLE OF yhska_14_prog,
      BEGIN OF ts_language,
        language TYPE string,
        year     TYPE string,
        url      TYPE string,
      END OF ts_language.
    METHODS:
      get_HTML
        IMPORTING im_url         TYPE string
        RETURNING VALUE(ex_html) TYPE string,
      filter_wiki
        IMPORTING im_html TYPE string
        EXPORTING ex_wiki TYPE TT_wiki.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS lcl_wiki_parser IMPLEMENTATION.

  METHOD get_HTML.
    DATA(lv_url) = im_url.
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

  METHOD filter_wiki.
    DATA(lv_html) = im_html.

    DATA: lt_languages   TYPE STANDARD TABLE OF ts_language,
          lt_timetables  TYPE STANDARD TABLE OF string,
          lt_table_lines TYPE STANDARD TABLE OF string,
          ls_language    TYPE ts_language,
          lv_timetable   TYPE string,
          lv_table_line  TYPE string,
          lv_language    TYPE string,
          lv_year        TYPE string,
          lv_url         TYPE string,
          lv_head        TYPE string,
          lv_tail        TYPE string,
          lv_index       TYPE i.

*        extract timetables
    SPLIT lv_html AT '<table class="wikitable sortable">' INTO TABLE lt_timetables.
*        remove head
    DELETE lt_timetables INDEX 1.

    LOOP AT lt_timetables INTO lv_timetable.

*          remove head
      SPLIT lv_timetable AT '</tr' INTO lv_head lv_timetable.
*          remove tail
      SPLIT lv_timetable AT '</table' INTO lv_timetable lv_tail.
      SPLIT lv_timetable AT '<tr' INTO TABLE lt_table_lines.
*          remove head
      DELETE lt_table_lines INDEX 1.
*          remove tail line
      lv_index = lines( lt_table_lines ).
      DELETE lt_table_lines INDEX lv_index.

      LOOP AT lt_table_lines INTO lv_table_line.
        SPLIT lv_table_line AT '<td>' INTO lv_head lv_year lv_language lv_tail.
        IF lv_language(1) EQ '<'.
          SPLIT lv_language AT 'href="' INTO lv_head Lv_language.
          SPLIT lv_language AT '"' INTO lv_url lv_language.
          SPLIT lv_language AT 'title="' INTO lv_head lv_language.
          SPLIT lv_language AT '"' INTO lv_language lv_tail.
          IF lv_url(3) EQ '/w/'.
            lv_url = ''.
          ELSE.
            CONCATENATE 'https://en.wikipedia.org' lv_url INTO lv_url.
          ENDIF.
          IF lv_url CA '#'.
            SPLIT lv_url AT '#' INTO lv_url lv_tail.
          ENDIF.
        ELSE.
          SPLIT lv_language AT '<' INTO lv_language lv_tail.
          lv_url = ''.
        ENDIF.
        SPLIT lv_language AT '(' INTO lv_language lv_tail.
        SPLIT lv_language AT |\n| INTO lv_language lv_tail.
        SPLIT lv_year AT '<' INTO lv_year lv_tail.
        SPLIT lv_year AT |\n| INTO lv_year lv_tail.
        SPLIT lv_year AT '–' INTO lv_year lv_tail.
        SPLIT lv_year AT '-' INTO lv_year lv_tail.
        SPLIT lv_year AT '?' INTO lv_year lv_tail.

        TRANSLATE lv_language TO UPPER CASE.
        ls_language-year = lv_year.
        ls_language-language = lv_language.
        ls_language-url = lv_url.
        APPEND ls_language TO lt_languages.
      ENDLOOP.
    ENDLOOP.

    SORT lt_languages BY url ASCENDING year ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_languages COMPARING url.
    DELETE lt_languages INDEX 1.
    SORT lt_languages BY language ASCENDING year ASCENDING.

*    LOOP AT lt_languages INTO ls_language.
*        concatenate ls_language-url '&redirect=no' into ls_language-url.
*        lv_html = me->get_html( exporting im_url = ls_language-url ).
*        if lv_html ca '"redirectText"'.
*            split lv_html at '"redirectText"' into lv_head lv_url.
*            split lv_url at 'href="' into lv_head lv_url.
*            split lv_url at '"' into lv_url lv_tail.
*            concatenate 'https://en.wikipedia.org' lv_url into ls_language-url.
*        endif.
*    ENDLOOP.

    SORT lt_languages BY url ASCENDING year ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_languages COMPARING url.
    SORT lt_languages BY language ASCENDING year ASCENDING.

    LOOP AT lt_languages INTO ls_language.

      DATA(ls_filler) = VALUE yhska_14_prog( name = ls_language-language
                                             releasedate = ls_language-year
                                             wikiurl = ls_language-url
                                                 ).
      APPEND ls_filler TO ex_wiki.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
