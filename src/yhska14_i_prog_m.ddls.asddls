@AbapCatalog.sqlViewName: 'YH14_VI_PROG_M'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Data model for Programming Languages'
define root view YHSKA14_I_PROG_M
  as select from yhska_14_prog
{     key name,
      @Semantics.amount.currencyCode: 'currency_code'
      shares,
      @Semantics.amount.currencyCode: 'currency_code'
      trends,
      @Semantics.amount.currencyCode: 'currency_code'
      rating,
      @Semantics.amount.currencyCode: 'currency_code'
      change,
      currentversion,
      @Semantics.currencyCode: true
      currency_code,
      releasedate,
      favorite,
      wikiurl,
      helloworld,
      @Semantics.user.lastChangedBy: true
      last_changed_by,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at
}
