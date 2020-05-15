*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lhc_prog DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.
    TYPES: tt_prog TYPE STANDARD TABLE OF yhska_14_prog.

    DATA:
      lt_pyplTable       TYPE STANDARD TABLE OF yhska_14_prog,
      lt_tiobeTable      TYPE STANDARD TABLE OF yhska_14_prog,
      lt_wikiTable       TYPE STANDARD TABLE OF yhska_14_prog,
      lt_helloworldTable TYPE STANDARD TABLE OF yhska_14_prog,
      lt_matchTable      TYPE STANDARD TABLE OF yhska_14_prog,
      ls_tableLine       TYPE yhska_14_prog.

    METHODS:
        download_data
            FOR MODIFY IMPORTING keys FOR ACTION prog~downloadData RESULT result,
        favorise
            FOR MODIFY IMPORTING keys FOR ACTION prog~favorise RESULT result,
        get_features
            FOR FEATURES IMPORTING keys REQUEST    requested_features FOR prog RESULT result,
        validate_favorite
            FOR VALIDATION prog~validateFav IMPORTING keys FOR prog,
        validate_stats
            FOR VALIDATION prog~validateStats IMPORTING keys FOR prog.


ENDCLASS.

CLASS lhc_prog IMPLEMENTATION.
*
  METHOD download_data.
    DATA(lo_pypl) = NEW ycl_pypl_parser( ).
    DATA(lo_tiobe) = NEW ycl_tiobe_parser( ).
    DATA(lo_wiki) = NEW ycl_wiki_parser( ).
    DATA(lo_hello) = NEW ycl_hello_world_parser( ).

    lo_pypl->get_table( IMPORTING ex_insertTable = lt_pyplTable ).
    lo_tiobe->get_table( IMPORTING ex_insertTable = lt_tiobeTable ).
    lo_wiki->get_table( IMPORTING ex_insertTable = lt_wikiTable ).
    lo_hello->get_table( IMPORTING ex_insertTable = lt_helloworldTable ).


    SELECT *
    FROM yhska_14_prog
    INTO TABLE @DATA(lt_prog).


    LOOP AT lt_pyplTable ASSIGNING FIELD-SYMBOL(<ls_pyplTable>).
      IF <ls_pyplTable> IS ASSIGNED.
        READ TABLE lt_prog
        WITH KEY name = <ls_pyplTable>-name
        INTO DATA(ls_prog).
        IF sy-subrc = 0.
          <ls_pyplTable>-favorite = ls_prog-favorite.
          <ls_pyplTable>-last_changed_by = ls_prog-last_changed_by.
          <ls_pyplTable>-last_changed_at = ls_prog-last_changed_at.
        ENDIF.
        IF <ls_pyplTable>-favorite IS INITIAL.
          <ls_pyplTable>-favorite = 0.
        ENDIF.
        READ TABLE lt_helloworldTable
            WITH KEY name = <ls_pyplTable>-name
            INTO DATA(ls_tableline).
        IF sy-subrc = 0.
          <ls_pyplTable>-helloworld = ls_tableline-helloworld.
        ENDIF.
        READ TABLE lt_tiobeTable
            WITH KEY name = <ls_pyplTable>-name
            INTO ls_tableline.
        IF sy-subrc = 0.
          <ls_pyplTable>-rating = ls_tableline-rating.
          <ls_pyplTable>-change = ls_tableline-change.
        ENDIF.
        READ TABLE lt_wikiTable
            WITH KEY name = <ls_pyplTable>-name
            INTO ls_tableline.
        IF sy-subrc = 0.
          <ls_pyplTable>-wikiurl = ls_tableline-wikiurl.
          <ls_pyplTable>-releasedate = ls_tableline-releasedate.
        ENDIF.
        <ls_pyplTable>-currency_code = '%'.
      ENDIF.
    ENDLOOP.

    MODIFY yhska_14_prog FROM TABLE @lt_pypltable.

        READ ENTITY yhska14_i_prog_m
        FIELDS ( name shares trends rating change currentversion currency_code
                 releasedate favorite wikiurl helloworld
                 last_changed_by last_changed_at )
         WITH VALUE #( FOR key2 IN keys (
                         name = key2-name
                       )
                     )
         RESULT DATA(lt_resutl)
         FAILED DATA(ls_failed)
         REPORTED DATA(ls_reported).

    result = VALUE #( FOR prog IN lt_resutl ( name = prog-name
                                                %param    = prog
                                              ) ).

  ENDMETHOD.

  METHOD favorise.

    READ ENTITY yhska14_i_prog_m
            FIELDS ( name shares trends rating change currentversion currency_code
                     releasedate favorite wikiurl helloworld
                     last_changed_by last_changed_at )
             WITH VALUE #( FOR key2 IN keys (
                             name = key2-name ) )
             RESULT DATA(lt_prog)
             FAILED DATA(ls_failed)
             REPORTED DATA(ls_reported).

    CLEAR: ls_failed, ls_reported.
    MODIFY ENTITY yhska14_i_prog_m
        UPDATE FIELDS ( favorite )
        WITH VALUE #( FOR ls_prog IN lt_prog (
                        name = ls_prog-name
                        favorite = COND #( WHEN ls_prog-favorite = '0'
                                           THEN '1' ELSE '0' ) ) )
        FAILED ls_failed
        REPORTED ls_reported.

    CLEAR: ls_failed, ls_reported.
    READ ENTITY yhska14_i_prog_m
        FIELDS ( name shares trends rating change currentversion currency_code
                 releasedate favorite wikiurl helloworld
                 last_changed_by last_changed_at )
         WITH VALUE #( FOR key2 IN keys (
                         name = key2-name
                       )
                     )
         RESULT DATA(lt_result)
         FAILED ls_failed
         REPORTED ls_reported.

    result = VALUE #( FOR prog IN lt_result ( name = prog-name
                                                %param    = prog
                                              ) ).
  ENDMETHOD.

  METHOD validate_favorite.
    READ ENTITY yhska14_i_prog_m
    FIELDS ( name favorite )
    WITH VALUE #( FOR key IN keys (
                    %key = key
                    %control-favorite = if_abap_behv=>mk-on ) )
    RESULT DATA(lt_favorites)
    FAILED DATA(ls_failed)
    REPORTED DATA(ls_reported).

    LOOP AT lt_favorites INTO DATA(ls_favorites).
        IF ls_favorites-favorite LT 0 OR ls_favorites-favorite GT 1.
            APPEND VALUE #( %key = ls_favorites-%key ) TO failed.
            APPEND VALUE #( %key = ls_favorites-%key
                            %msg = new_message(
                                id = 'YHSKA14_MSG'
                                number = '001'
                                v1 = ls_favorites-favorite
                                v2 = 'Set Favorite'
                                severity = if_abap_behv_message=>severity-error )
                                %element-favorite = if_abap_behv=>mk-on ) TO REPORTED.
        ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_stats.
    READ ENTITY yhska14_i_prog_m
    FIELDS ( name shares rating )
    WITH VALUE #( FOR key IN keys (
                    %key = key
                    %control = VALUE #( shares = if_abap_behv=>mk-on
                                        rating = if_abap_behv=>mk-on ) ) )
    RESULT DATA(lt_stats)
    FAILED DATA(ls_failed)
    REPORTED DATA(ls_reported).

    LOOP AT lt_stats INTO DATA(ls_stats).

        IF ls_stats-shares LT 0 OR ls_stats-shares GT 100.
            APPEND VALUE #( %key = ls_stats-%key ) TO failed.
            APPEND VALUE #( %key = ls_stats-%key
                            %msg = new_message(
                                id = 'YHSKA14_MSG'
                                number = '002'
                                v1 = ls_stats-shares
                                v2 = 'Save Shares'
                                severity = if_abap_behv_message=>severity-error )
                                %element-shares = if_abap_behv=>mk-on ) TO REPORTED.
        ELSEIF ls_stats-rating LT 0 OR ls_stats-rating GT 100.
            APPEND VALUE #( %key = ls_stats-%key ) TO failed.
            APPEND VALUE #( %key = ls_stats-%key
                            %msg = new_message(
                                id = 'YHSKA14_MSG'
                                number = '002'
                                v1 = ls_stats-rating
                                v2 = 'Save Rating'
                                severity = if_abap_behv_message=>severity-error )
                                %element-rating = if_abap_behv=>mk-on ) TO REPORTED.
        ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_features.

    READ ENTITY yhska14_i_prog_m
    FIELDS ( favorite )
    WITH VALUE #( FOR keyval IN keys
                  (  %key                    = keyval-%key ) )
    RESULT DATA(lt_favorite).


    result = VALUE #( FOR ls_favorite IN lt_favorite
                       ( %key                           = ls_favorite-%key
                         %features-%action-favorise = if_abap_behv=>fc-o-enabled )
                      ).
  ENDMETHOD.

ENDCLASS.
