@..\..\install_prereq\initspool install_sf_epa_investigations

DROP TABLE investigation_details 
/
CREATE TABLE investigation_details  (
   id                 NUMBER GENERATED ALWAYS AS IDENTITY,
   investigation_id   NUMBER,
   spray_id           NUMBER,
   pesticide_id       NUMBER
)
/
PROMPT Add the ut records
BEGIN
  Trapit.Add_Ttu('TT_Investigation_Mgr',    'Purely_Wrap_Investigation_Mgr',  'UT_EXAMPLES', 'Y', 'sf_epa_investigations.json');
END;
/

PROMPT Packages creation
PROMPT =================

PROMPT Create package Investigation_Mgr
@investigation_mgr.pks
@investigation_mgr.pkb

PROMPT Create package TT_Investigation_Mgr
@tt_investigation_mgr.pks
@tt_investigation_mgr.pkb

PROMPT Call procedure as example three times...
BEGIN
   investigation_mgr.pack_details(
      p_investigation_id  => 100,
      p_pesticide_id      => 123,
      p_spray_id          => 789
   );

   investigation_mgr.pack_details(
      p_investigation_id  => 100,
      p_pesticide_id      => 123,
      p_spray_id          => 789
   );

   investigation_mgr.pack_details(
      p_investigation_id  => 100,
      p_pesticide_id      => null,
      p_spray_id          => 789
   );
END;
/
l
PROMPT Example data created by calls...
SELECT id, investigation_id, spray_id, pesticide_id    
  FROM investigation_details 
 ORDER BY 1
/
ROLLBACK
/
@..\..\install_prereq\endspool