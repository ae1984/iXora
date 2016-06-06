/* afnf.p
 * MODULE
        Отчет по кодам доходов/расходов операций
 * DESCRIPTION
        Отчет по кодам доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-cods.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-7-3-14
 * AUTHOR
       01/04/2011
 * BASES
	COMM, TXB
 * CHANGES
   kapar - 06.12.2012 СЗ включить в данный отчет возможность выгрузки детализированных данных в разрезе заемщиков
*/

def shared temp-table lnpr
  field id      as   int
  field name    as   char
  field nsum    as   decimal extent 4
  field tsum    as   decimal extent 4.

def shared temp-table dlnpr
  field id      as   int
  field cif     as   char
  field cname   as   char
  field lon     as   char
  field nsum    as   decimal extent 4
  field tsum    as   decimal extent 4.

def shared var v-date1 as date.
def shared var v-date2 as date.
def shared var v-sel   as deci.

find first txb.cmp no-lock no-error.
if avail txb.cmp then do:
 create lnpr.
  lnpr.id = int(txb.cmp.code).
  lnpr.name = txb.cmp.name.
end.

def var i as integer no-undo.
def var lst_grp as char no-undo init ''.
def var v-grp as integer no-undo.

def var bal11 as deci no-undo.
def var pol_proc as deci no-undo.

/*---------ЮЛ, МСБ-----------------*/
lst_grp = '10,11,14,15,16,21,24,25,26,50,54,55,56,64,65,66,70,80'.
find last lnpr where lnpr.id = int(txb.cmp.code) no-lock no-error.
if avail lnpr then do:
  lnpr.tsum[1] = 0.  lnpr.tsum[2] = 0. lnpr.tsum[3] = 0. lnpr.tsum[4] = 0.
end.
do i = 1 to num-entries(lst_grp):
    v-grp = integer(entry(i,lst_grp)).
    for each txb.lon where txb.lon.grp = v-grp no-lock:
        run lonbalcrc_txb('lon',txb.lon.lon,v-date1,"11",no,1,output bal11).
        bal11 = - bal11.
        run lonbalcrc_txb('lon',txb.lon.lon,v-date1,"12",no,1,output pol_proc).
        pol_proc = - pol_proc.

        if (day(v-date1) = 1) and (month(v-date1) = 1)  then do:
         bal11 = 0.
         pol_proc = 0.
        end.
        else do:
         if (bal11 = 0) and (pol_proc = 0) then next.
        end.


        find last lnpr where lnpr.id = int(txb.cmp.code) no-lock no-error.
        if avail lnpr then do:
          lnpr.tsum[1] = lnpr.tsum[1] + bal11.
          lnpr.tsum[2] = lnpr.tsum[2] + pol_proc.
        end.

        find last txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        find last dlnpr where dlnpr.id = int(txb.cmp.code) and dlnpr.lon = txb.lon.lon  no-lock no-error.
        if not avail dlnpr then do:
           create dlnpr.
             dlnpr.id = int(txb.cmp.code).
             dlnpr.cif = txb.lon.cif.
             dlnpr.cname = txb.cif.name.
             dlnpr.lon = txb.lon.lon.
             dlnpr.tsum[1] = bal11.
             dlnpr.tsum[2] = pol_proc.
        end.
        else do:
             dlnpr.id = int(txb.cmp.code).
             dlnpr.cif = txb.lon.cif.
             dlnpr.cname = txb.cif.name.
             dlnpr.lon = txb.lon.lon.
             dlnpr.tsum[1] = bal11.
             dlnpr.tsum[2] = pol_proc.
        end.

    end. /* for each txb.lon */
end. /* do i = 1 to */

do i = 1 to num-entries(lst_grp):
    v-grp = integer(entry(i,lst_grp)).
    for each txb.lon where txb.lon.grp = v-grp no-lock:
        run lonbalcrc_txb('lon',txb.lon.lon,v-date2,"11",no,1,output bal11).
        bal11 = - bal11.
        run lonbalcrc_txb('lon',txb.lon.lon,v-date2,"12",no,1,output pol_proc).
        pol_proc = - pol_proc.

        if (bal11 = 0) and (pol_proc = 0) then next.

        find last lnpr where lnpr.id = int(txb.cmp.code) no-lock no-error.
        if avail lnpr then do:
          lnpr.tsum[3] = lnpr.tsum[3] + bal11.
          lnpr.tsum[4] = lnpr.tsum[4] + pol_proc.
        end.

        find last txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        find last dlnpr where dlnpr.id = int(txb.cmp.code) and dlnpr.lon = txb.lon.lon  no-lock no-error.
        if not avail dlnpr then do:
           create dlnpr.
             dlnpr.id = int(txb.cmp.code).
             dlnpr.cif = txb.lon.cif.
             dlnpr.cname = txb.cif.name.
             dlnpr.lon = txb.lon.lon.
             dlnpr.tsum[3] = bal11.
             dlnpr.tsum[4] = pol_proc.
        end.
        else do:
             dlnpr.id = int(txb.cmp.code).
             dlnpr.cif = txb.lon.cif.
             dlnpr.cname = txb.cif.name.
             dlnpr.lon = txb.lon.lon.
             dlnpr.tsum[3] = bal11.
             dlnpr.tsum[4] = pol_proc.
        end.

        dlnpr.nsum[1] = dlnpr.tsum[3] - dlnpr.tsum[1].
        dlnpr.nsum[2] = dlnpr.tsum[4] - dlnpr.tsum[2].

    end. /* for each txb.lon */
end. /* do i = 1 to */

find last lnpr where lnpr.id = int(txb.cmp.code) no-lock no-error.
if avail lnpr then do:
  lnpr.nsum[1] = lnpr.tsum[3] - lnpr.tsum[1].
  lnpr.nsum[2] = lnpr.tsum[4] - lnpr.tsum[2].
end.


/*--------ФЛ-----------------*/
lst_grp = '20,27,28,60,67,68,81,82,90,92'.
find last lnpr where lnpr.id = int(txb.cmp.code) no-lock no-error.
if avail lnpr then do:
  lnpr.tsum[1] = 0.  lnpr.tsum[2] = 0. lnpr.tsum[3] = 0. lnpr.tsum[4] = 0.
end.
do i = 1 to num-entries(lst_grp):
    v-grp = integer(entry(i,lst_grp)).
    for each txb.lon where txb.lon.grp = v-grp no-lock:
        run lonbalcrc_txb('lon',txb.lon.lon,v-date1,"11",no,1,output bal11).
        bal11 = - bal11.
        run lonbalcrc_txb('lon',txb.lon.lon,v-date1,"12",no,1,output pol_proc).
        pol_proc = - pol_proc.

        if (day(v-date1) = 1) and (month(v-date1) = 1)  then do:
         bal11 = 0.
         pol_proc = 0.
        end.
        else do:
         if (bal11 = 0) and (pol_proc = 0) then next.
        end.

        find last lnpr where lnpr.id = int(txb.cmp.code) no-lock no-error.
        if avail lnpr then do:
          lnpr.tsum[1] = lnpr.tsum[1] + bal11.
          lnpr.tsum[2] = lnpr.tsum[2] + pol_proc.
        end.

        find last txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        find last dlnpr where dlnpr.id = int(txb.cmp.code) and dlnpr.lon = txb.lon.lon  no-lock no-error.
        if not avail dlnpr then do:
           create dlnpr.
             dlnpr.id = int(txb.cmp.code).
             dlnpr.cif = txb.lon.cif.
             dlnpr.cname = txb.cif.name.
             dlnpr.lon = txb.lon.lon.
             dlnpr.tsum[1] = bal11.
             dlnpr.tsum[2] = pol_proc.
        end.
        else do:
             dlnpr.id = int(txb.cmp.code).
             dlnpr.cif = txb.lon.cif.
             dlnpr.cname = txb.cif.name.
             dlnpr.lon = txb.lon.lon.
             dlnpr.tsum[1] = bal11.
             dlnpr.tsum[2] = pol_proc.
        end.

    end. /* for each txb.lon */
end. /* do i = 1 to */

do i = 1 to num-entries(lst_grp):
    v-grp = integer(entry(i,lst_grp)).
    for each txb.lon where txb.lon.grp = v-grp no-lock:
        run lonbalcrc_txb('lon',txb.lon.lon,v-date2,"11",no,1,output bal11).
        bal11 = - bal11.
        run lonbalcrc_txb('lon',txb.lon.lon,v-date2,"12",no,1,output pol_proc).
        pol_proc = - pol_proc.

        if (bal11 = 0) and (pol_proc = 0) then next.

        find last lnpr where lnpr.id = int(txb.cmp.code) no-lock no-error.
        if avail lnpr then do:
          lnpr.tsum[3] = lnpr.tsum[3] + bal11.
          lnpr.tsum[4] = lnpr.tsum[4] + pol_proc.
        end.

        find last txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        find last dlnpr where dlnpr.id = int(txb.cmp.code) and dlnpr.lon = txb.lon.lon  no-lock no-error.
        if not avail dlnpr then do:
           create dlnpr.
             dlnpr.id = int(txb.cmp.code).
             dlnpr.cif = txb.lon.cif.
             dlnpr.cname = txb.cif.name.
             dlnpr.lon = txb.lon.lon.
             dlnpr.tsum[3] = bal11.
             dlnpr.tsum[4] = pol_proc.
        end.
        else do:
             dlnpr.id = int(txb.cmp.code).
             dlnpr.cif = txb.lon.cif.
             dlnpr.cname = txb.cif.name.
             dlnpr.lon = txb.lon.lon.
             dlnpr.tsum[3] = bal11.
             dlnpr.tsum[4] = pol_proc.
        end.

        dlnpr.nsum[3] = dlnpr.tsum[3] - dlnpr.tsum[1].
        dlnpr.nsum[4] = dlnpr.tsum[4] - dlnpr.tsum[2].

    end. /* for each txb.lon */
end. /* do i = 1 to */

find last lnpr where lnpr.id = int(txb.cmp.code) no-lock no-error.
if avail lnpr then do:
  lnpr.nsum[3] = lnpr.tsum[3] - lnpr.tsum[1].
  lnpr.nsum[4] = lnpr.tsum[4] - lnpr.tsum[2].
end.

