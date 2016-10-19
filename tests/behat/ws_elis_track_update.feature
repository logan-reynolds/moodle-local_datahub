@local @local_datahub
Feature: Web service requests can be made to update a track.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS programs exist:
          | name | idnumber | reqcredits |
          | TestProgram | TestProgramIdnumber | 12.34 |
        And the following ELIS tracks exist:
          | program_idnumber | name | idnumber |
          | TestProgramIdnumber | TestTrack | TestTrackIdnumber | 

    #T33.26.26 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_update" method with body:
         | body |
         | |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    #T33.26.26 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_update" method with body:
         | body |
         | {} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    #T33.26.26 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_update" method with body:
         | body |
         | {"data":{}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.26 #4
    Scenario: Missing idnumber field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_update" method with body:
         | body |
         | {"data":{"name":"TestTrack"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: idnumber"} |

    # T33.26.26 #5
    Scenario: Invalid idnumber field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_update" method with body:
         | body |
         | {"data":{"name":"TestTrack","idnumber":"BogusTrackIdnumber"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_track_update_fail_invalid_idnumber","message":"Track idnumber: 'BogusTrackIdnumber' is not a valid track."} |

    # T33.26.26 #6
    Scenario: Successfully update track.
       Given I make a datahub webservice request to the "local_datahub_elis_track_update" method with body:
         | body |
         | {"data":{"name":"NewTestTrack","idnumber":"TestTrackIdnumber","description":"test track description","autocreate":1}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"track_updated","message":"Track updated successfully","record":{"idnumber":"TestTrackIdnumber","name":"NewTestTrack","description":"test track description","startdate":0,"enddate":0}} |

    # T33.26.26 #7
    Scenario: Create with invalid multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | track | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_track_update" method with body:
         | body |
         | {"data":{"idnumber":"TestTrackIdnumber","field_custom1":"Option E"}} |
        Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"track_updated","message":"Track updated with custom field errors - see logs for details.","record":{"idnumber":"TestTrackIdnumber","name":"TestTrack","description":"Description of the Track","startdate":0,"enddate":0,"field_custom1":"Option 4"}} |

    # T33.26.26 #7.1
    Scenario: Create with valid multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | track | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_track_update" method with body:
         | body |
         | {"data":{"idnumber":"TestTrackIdnumber","field_custom1":"Option 1,Option 3"}} |
        Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"track_updated","message":"Track updated successfully","record":{"idnumber":"TestTrackIdnumber","name":"TestTrack","description":"Description of the Track","startdate":0,"enddate":0,"field_custom1":"Option 1,Option 3"}} |

