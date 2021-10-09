CREATE OR REPLACE package investigation_mgr authid definer
is
/*
This package is copied (with some minor re-formatting) from Steven Feuerstein's article of 5 May 2021:

[Feuertip #8: “On the cheap” testing](https://www.insum.ca/feuertip-8-on-the-cheap-testing/)

It is used here as an example to demonstrate unit testing.
*/
   procedure pack_details (
      p_investigation_id  in  number,
      p_spray_id          in  number,
      p_pesticide_id      in  number
   );
end;
/
SHO ERR