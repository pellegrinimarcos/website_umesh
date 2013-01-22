Rem
Rem $Header: ctxf101.sql 25-may-2004.11:14:29 ehuang Exp $
Rem
Rem ctxf101.sql
Rem
Rem Copyright (c) 2003, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      ctxf101.sql - CTX list of Files to copy when upgrading from
Rem                    10.1.0 to current version
Rem
Rem    DESCRIPTION
Rem      This script is used by the installer during upgrade.
Rem
Rem      It must be run as database user SYS, SYSTEM, or CTXSYS.
Rem      It must be run post-upgrade of Text database objects.
Rem
Rem      It SELECTs the list of files which are not listed in
Rem      ship_it but must be copied from old ORACLE_HOME to new
Rem      ORACLE_HOME when upgrading.  The reason these files are not
Rem      listed in ship_it is that these files are generated by the
Rem      user via the Text user-extensible features.
Rem
Rem      The filenames SELECTed are relative to ORACLE_HOME directory.
Rem      The UNIX style directory separator is used ('/') herein.  On platforms
Rem      which use a different directory separator (e.g. '\' on Windows)
Rem      the installer will take care of re-writing the fully-qualified
Rem      path to the file.
Rem
Rem      Some or all of these files may not exist in the old ORACLE_HOME
Rem      depending on which Text user-extensible features were used
Rem      prior to upgrading.
Rem
Rem      This file is not a substitute for ctxf101.txt.  Instead the
Rem      installer must union the list of files here with the list
Rem      of files in ctxf101.txt.
Rem
Rem    NOTES
Rem      See bug 3271648.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ehuang      05/25/04 - ehuang_bug-3271648
Rem    ehuang      05/20/04 - creation
Rem

set serveroutput on
declare
  odma varchar2(30) := 'ODMA_DIRECTIVE:COPY_FILE:';
begin
  -- user filter is in different places on windows and non-windows.
  -- since there is no easy way to tell in pl/sql what the platform is
  -- and since we are ignoring file not found errors anyway, we just
  -- output both.
  for c in (select ixv_value
               from ctxsys.ctx_index_values
              where ixv_class = 'FILTER'
                and ixv_object = 'USER_FILTER'
                and ixv_attribute = 'COMMAND')
  loop
    dbms_output.put_line(odma||'bin/'||c.ixv_value||':');
    dbms_output.put_line(odma||'ctx/bin/'||c.ixv_value||':');
  end loop;

  -- japanese/chinese compiled extensible lexicon files
  -- currently must be manually re-extended after upgrade

  -- mail filter configuration file
  for c in (select par_value from ctxsys.ctx_parameters
             where par_name = 'MAIL_FILTER_CONFIG_FILE')
  loop
    if (upper(c.par_value) != 'DRMAILFL.TXT') then
      dbms_output.put_line(odma||'ctx/config/'||c.par_value||':');
    end if;
  end loop;
end;
/

