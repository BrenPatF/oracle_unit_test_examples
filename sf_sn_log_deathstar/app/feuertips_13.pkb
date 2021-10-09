CREATE OR REPLACE PACKAGE BODY Feuertips_13 IS

PROCEDURE Feuertips_13_POC IS

   k_full_date_format  constant varchar2(20) := 'mm/dd/yy';
   k_half_date_format  constant varchar2(20) := 'mm/yyyy';
   k_file1_name        constant varchar2(20) := 'room_action.log';
   k_file2_name        constant varchar2(20) := 'room_repair.log';
   l_file1_lines       L1_chr_arr;
   l_file2_lines       L1_chr_arr;
   l_file1_lines_cnt   number := 0;
   l_file2_lines_cnt   number := 0;
   l_file1_line        varchar2(4000);
   l_file2_line        varchar2(4000);
   l_file1_name        varchar2(100) := k_file1_name;
   l_file2_name        varchar2(100) := k_file2_name;
   l_current_key       number default 0;
   l_first_time        number default 0;

   procedure init as
   begin
      l_file1_lines  := L1_chr_arr();
      l_file2_lines  := L1_chr_arr();
   end init;

   procedure print_lines (
      p_file_name  in  varchar2,
      p_lines      in  L1_Chr_Arr
   ) as
      l_file utl_file.file_type;
   begin
      l_file := utl_file.fopen('INPUT_DIR', p_file_name, 'w');
      for i in p_lines.first..p_lines.last loop
--      for i in 1..p_lines.count loop
         utl_file.put_line(l_file, p_lines(i));
      end loop;
      utl_file.fclose (l_file);
   end print_lines;

   procedure add_line (
      p_file_name  in  varchar2,
      p_line       in  varchar2
   ) as
   begin
      case p_file_name
         when k_file1_name then
            l_file1_lines.extend();
            l_file1_lines(l_file1_lines.count)      := p_line;
            l_file1_lines_cnt                        := l_file1_lines_cnt + 1;
         when k_file2_name then
            l_file2_lines.extend();
            l_file2_lines(l_file2_lines.count)      := p_line;
            l_file2_lines_cnt                        := l_file2_lines_cnt + 1;
      end case;
   end add_line;

begin
   init;
   for crs in (
      select *
        from log_deathstar_room_access
   ) loop
      case
         when l_current_key != crs.key_id then
            l_first_time   := 1;
            l_current_key  := crs.key_id;
         else
            l_first_time := 2;
      end case;

      if l_first_time = 1 then
         for crs2 in (
            select *
              from log_deathstar_room_actions
              where key_id = crs.key_id
         ) loop
            l_file1_line := crs.key_id
                            || '|'
                            || crs.room_name
                            || '|'
                            || crs2.done_by
                            || '|'
                            || crs2.action;

            add_line(
               p_file_name  => k_file1_name,
               p_line       => l_file1_line
            );
         end loop;
      end if;

   end loop;

   print_lines(l_file1_name, l_file1_lines);

    /* Next! */

   for crs in (
      select *
        from log_deathstar_room_access) loop
      case
         when l_current_key != crs.key_id then
            l_first_time   := 1;
            l_current_key  := crs.key_id;
         else
            l_first_time := 2;
      end case;

      if l_first_time = 1 then
         for crs2 in (
            select *
              from log_deathstar_room_repairs
              where key_id = crs.key_id) loop
            l_file2_line := crs.key_id
                            || '|'
                            || crs.room_name
                            || '|'
                            || crs2.repair_completion
                            || '|'
                            || crs2.repaired_by
                            || '|'
                            || crs2.action;

            add_line(
               p_file_name  => k_file2_name,
               p_line       => l_file2_line
            );
         end loop;
      end if;

   end loop;

   print_lines(l_file2_name, l_file2_lines);

    /* And so on.... */
END Feuertips_13_POC;

END Feuertips_13;
/
SHO ERR