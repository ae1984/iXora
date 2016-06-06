/* lcrep1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Reports - Turnover
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        lcrep1f.p lcrep1.i
 * MENU
        14-7-3-1
* BASES
        BANK COMM
 * AUTHOR
        21/11/11 id00810
 * CHANGES
        10.07.2012 Lyubov  - добавила поля "Дата окончания" и "Статус"
*/

{mainhead.i}

{lcrep1.i "new shared"}

def new shared temp-table wrk no-undo
  field bank     as char
  field bankn    as char
  field gl       as int
  field crc      as int
  field crc_code as char
  field jdt      as date
  field jh       as int
  field dam      as deci
  field cam      as deci
  field dam_KZT  as deci
  field cam_KZT  as deci
  field who      as char
  field lcprod   as char
  field lc       as char
  field cif      as char
  field cif_name as char
  field expdt    as char
  field sts      as char
  index idx is primary gl lcprod jdt jh.

def var v-branch   as log  no-undo.
def var v-tdam     as deci no-undo.
def var v-tcam     as deci no-undo.
def var v-tdam_all as deci no-undo.
def var v-tcam_all as deci no-undo.

form
v-from   label "         From" help "Input the beg date " skip
v-to     label "           To" help "Input the end date " skip
v-glacc  label "Ledger Account" format ">>>>>>" validate(can-find(codfr where codfr.codfr = 'lcledger' and codfr.code = string(v-glacc) no-lock),'Enter the ledger account!') help "Enter Ledger Account,F2 - help" skip
v-cif    label "Applicant code" format "x(06)" validate(can-find(cif where cif.cif = v-cif no-lock) or v-cif = '*','Enter the applicant code or * for all codes!') help "Enter the applicant code or * for all codes, F2 - help"
with row 8 centered  side-label frame opt title " LC Reports: Turnover ".

on help of v-glacc in frame opt do:
    {itemlist.i
     &file = "codfr"
     &frame = "row 6 centered scroll 1 20 down width 91 overlay "
     &where = " codfr.codfr = 'lcledger' "
     &chtype = "string"
     &flddisp = "codfr.code label 'Code' format '999999' codfr.name[1] label 'Name' format 'x(25)' "
     &chkey = "code"
     &index = "cdco_idx"
     &end = "if keyfunction(lastkey) = 'end-error' then return."
     }
     v-glacc = int(codfr.code).
     display v-glacc with frame opt.
end.
update v-from v-to v-glacc v-cif with frame opt.
hide frame  opt.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display "There is no record OURBNK in bank.sysc file!".
   pause.
   return.
end.

find first txb where txb.bank = sysc.chval and txb.consolid no-lock no-error.
if not avail txb then return.
if txb.is_branch then v-branch = true.

find first gl where gl.gl = v-glacc no-lock no-error.
if not avail gl then return.
v-lev = gl.level.

find first codfr where codfr.codfr = 'lcledger' and codfr.code = string(v-glacc) no-lock no-error.
if not avail codfr then return.
v-splcprod = if codfr.name[2] = '' then '' else trim(codfr.name[2]).
v-cover  = if codfr.name[3] = '' then ''  else if trim(codfr.name[3]) = 'covered' then '0' else '1'.
v-code = if codfr.name[4] = '' then '' else trim(codfr.name[4]).
v-com = if string(v-glacc) begins '4' then yes else no.
if v-branch = true then do:
    if connected ("txb") then disconnect "txb".
    find first txb where txb.bank = sysc.chval and txb.consolid no-lock no-error.
    connect value(" -db " + replace(txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
    run lcrep1f(txb.name).
    if connected ("txb") then disconnect "txb".
end.
else do:
    {r-brfilial.i &proc = "lcrep1f (txb.info)"}
end.

def stream m-out.
output stream m-out to lcrep1.htm.

put stream m-out unformatted "<html><head><title>METROCOMBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

find first cmp no-lock no-error.
put stream m-out unformatted "<br><br>" cmp.name "<br>" skip.

if v-select > 1 then do:
    find first txb where txb.txb = (v-select - 2) no-lock no-error.
    put stream m-out unformatted txb.info "<br>" skip.
end.

for each wrk no-lock break by wrk.gl by wrk.lcprod by wrk.lc:
    if first-of(wrk.gl) then do:
        put stream m-out unformatted "<br>" "ОБОРОТЫ ПО СЧЕТУ " + string(wrk.gl).
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then put stream m-out unformatted " " + gl.des.
        put stream m-out unformatted
            "<br>" skip
            "ЗА ПЕРИОД С " v-from " ПО " v-to "<br>" skip.
        if v-cif ne '*' then  put stream m-out unformatted
                            "<br>" skip
                            "КЛИЕНТ: " wrk.cif_name  "<br>" skip.
        put stream m-out unformatted "</tr></table>" skip.
        put stream m-out unformatted "<br>" skip.
        put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Продукт</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Референс</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Клиент</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Филиал</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дт</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Кт</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дт_KZT</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Кт_KZT</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ID</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Транз</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата оконч.</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Статус</td>"
                  "</tr>" skip.
    end.
    if first-of(wrk.lcprod) then do:
        assign v-tdam = 0 v-tcam = 0.
        put stream m-out unformatted
              "<tr>"
              "<td>" wrk.lcprod "</td>"
              "<td>" wrk.lc "</td>".
    end.
    else put stream m-out unformatted
              "<tr>"
              "<td>" "</td>"
              "<td>"  wrk.lc "</td>".
    put stream m-out unformatted
              "<td>" wrk.cif_name "</td>"
              "<td>" wrk.bankn "</td>"
              "<td>" wrk.jdt "</td>"
              "<td>" wrk.crc_code "</td>"
              "<td>" replace(trim(string(wrk.dam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.cam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.dam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.cam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" wrk.who "</td>"
              "<td>" wrk.jh "</td>"
              "<td>" wrk.expdt "</td>"
              "<td>" wrk.sts "</td>"
              "</tr>" skip.

    v-tdam = v-tdam + wrk.dam_KZT.
    v-tcam = v-tcam + wrk.cam_KZT.
    v-tdam_all = v-tdam_all + wrk.dam_KZT.
    v-tcam_all = v-tcam_all + wrk.cam_KZT.

    if last-of(wrk.lcprod) then do:
        put stream m-out unformatted
              "<tr>"
              "<td>" wrk.lcprod "</td>"
              "<td colspan=7>ИТОГО ОБОРОТЫ ПО ПРОДУКТУ </td>"
              "<td>" replace(trim(string(v-tdam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(v-tcam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td></td>"
              "<td></td>"
              "</tr>" skip.

    end.
    if last-of(wrk.gl) then do:
        put stream m-out unformatted
              "<tr>"
              "<td colspan=8>ВСЕГО </td>"
              "<td>" replace(trim(string(v-tdam_all,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(v-tcam_all,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td></td>"
              "<td></td>"
              "</tr>" skip.
        put stream m-out unformatted "</table><br>" skip.

    end.
end.

output stream m-out close.
unix silent cptwin lcrep1.htm excel.
