@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection view for Prog languages'


@UI: {
 headerInfo: { typeName: 'Programming Language', typeNamePlural: 'Programming Languages', title: { type: #STANDARD, value: 'ProgName' } } }

@Search.searchable: true

define root view entity YHSKA14_C_PROG_M
  as projection on YHSKA14_I_PROG_M
{
      @UI.facet: [ 
                   { id:              '1',
                     purpose:         #STANDARD,
                     type:            #IDENTIFICATION_REFERENCE,
                     label:           'Details',
                     position:        20 } ]
      @UI: {
               lineItem:       [ { position: 10, importance: #HIGH, label: 'Programming Language' }, 
                                 { type: #FOR_ACTION, dataAction: 'downloadData', label: 'Parse Data' } ],
               identification: [ { position: 10, label: 'Programming Language' } ] }
      @Search.defaultSearchElement: true
  key name            as ProgName,

      @UI: {
              lineItem:       [ { position: 20, type: #AS_DATAPOINT  } ],
              identification: [ { position: 20, label: 'Shares (PYPL in %)' }  ],
              selectionField: [ { position: 20 } ],
              dataPoint: { title: 'Shares (PYPL in %)',
                           visualization: #PROGRESS,
                           targetValue: 100 } }
      shares          as Shares,

      @UI: {
              lineItem:       [ { position: 30, importance: #HIGH, label: 'Trends (PYPL in %)' } ],
              identification: [ { position: 30, label: 'Trends (PYPL in %)' } ],
              selectionField: [ { position: 30 } ] }
      trends          as Trends,

      @UI: {
              lineItem:       [ { position: 40, importance: #HIGH, type: #AS_DATAPOINT } ],
              identification: [ { position: 40, label: 'Rating (TIOBE in %)' } ],
              selectionField: [ { position: 40 } ],
              dataPoint: { title: 'Rating (TIOBE in %)',
                           visualization: #PROGRESS,
                           targetValue: 100 } }
      rating          as Rating,
      @UI: {
              lineItem:       [ { position: 50, importance: #HIGH, label: 'Change (TIOBE in %)' } ],
              identification: [ { position: 50, label: 'Change (TIOBE in %)' } ],
              selectionField: [ { position: 50 } ] }
      change          as Change,
      
      @UI.hidden: true
      currentversion  as CurrentVersion,
      @UI.hidden: true
      currency_code   as CurrencyCode,
      
      @UI: {
          lineItem:       [ { position: 70, importance: #MEDIUM, label: 'Release Date' } ],
          identification: [ { position: 70, label: 'Release Date' } ] }
      releasedate     as ReleaseDate,
      
      @UI: {
          lineItem:       [ { position: 80, importance: #LOW, type: #AS_DATAPOINT },
                            { type: #FOR_ACTION, dataAction: 'favorise', label: 'Set Favorite' } ],
          identification: [ { position: 10, label: 'Favorite' } ],
          dataPoint: { title: 'Favorite',
                           visualization: #RATING,
                           targetValue: 1 } }
      favorite        as Favorite,
      
      @UI.identification: [{ position: 90, label: 'Wikipedia Link' }]
      wikiurl         as WikipediaLink,
      
      @UI: { identification: [{ position: 110, label: 'Hello World Example' }],
             multiLineText: true }
      helloworld      as HelloWorld,
      
      @UI.hidden: true
      last_changed_by as LastChangedBy,
      @UI.hidden: true
      last_changed_at as LastChangedAt
}
