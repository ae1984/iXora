/* lcrep2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Reports - Remaining Amount
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        lcrep2f.p lcrep2.i
 * MENU
        14-7-3-2
 * BASES
        BANK COMM
 * AUTHOR
        29/11/11 id00810
 * CHANGES
*/

{mainhead.i}

{lcrep2.i "new shared"}

def new shared temp-table wrk no-undo
  field bank     as char
  field bankn    as char
  field gl       as int
  field crc      as int
  field crc_code as char
  field ost      as deci
  field ost_KZT  as deci
  field lcprod   as char
  field lc       as char
  field cif      as char
  field cif_name as char
  index idx is primary gl lcprod lc.

def var v-branch  as log  no-undo.
def var v-ost     as deci no-undo.
def var v-ost_all as deci no-undo.

form
v-dt     label "         Date" help "Input the date " skip
v-glacc  label "Ledger Account" format ">>>>>>" validate(can-find(codfr where codfr.codfr = 'lcledger' and codfr.code = string(v-glacc) no-lock),'Enter the ledger account!') help "Enter Ledger Account,F2 - help" skip
v-cif    label "Applicant code" format "x(06)" validate(can-find(cif where cif.cif = v-cif no-lock) or v-cif = '*','Enter the applicant code or * for all codes!') help "Enter the applicant code or * for all codes, F2 - help"
with row 8 centered  side-label frame opt title " LC Reports: Remaining Amount ".

on help of v-glacc in frame opt do:
    {itemlist.i
     &file    = "codfr"
     &frame   = "row 6 centered scroll 1 20 down width 91 overlay "
     &where   = " codfr.codfr = 'lcledger' "
     &chtype  = "string"
     &flddisp = "codfr.code label 'Code' format '999999' codfr.name[1] label 'Name' format 'x(25)' "
     &chkey   = "code"
     &index   = "cdco_idx"
     &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
     v-glacc = int(codfr.code).
     display v-glacc with frame opt.
end.
update v-dt v-glacc v-cif with frame opt.
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
assign v-lev = gl.level
       v-ap  = if lookup(gl.type, "a,e") > 0 then yes else no.

find first codfr where codfr.codfr = 'lcledger' and codfr.code = string(v-glacc) no-lock no-error.
if not avail codfr then return.
assign v-splcprod = if codfr.name[2] = '' then '' else trim(codfr.name[2])
       v-cover    = if codfr.name[3] = '' then ''  else if trim(codfr.name[3]) = 'covered' then '0' else '1'
       v-code     = if codfr.name[4] = '' then '' else trim(codfr.name[4])
       v-com      = if string(v-glacc) begins '4' then yes else no.

if v-branch = true then do:
    if connected ("txb") then disconnect "txb".
    find first txb where txb.bank = sysc.chval and txb.consolid no-lock no-error.
    connect value(" -db " + replace(txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
    run lcrep2f(txb.name).
    if connected ("txb") then disconnect "txb".
end.
else do:
    {r-brfilial.i &proc = "lcrep2f (txb.info)"}
end.

def stream m-out.
output stream m-out to lcrep2.htm.

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
        put stream m-out unformatted "<br>" "ОСТАТКИ ПО СЧЕТУ " + string(wrk.gl).
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then put stream m-out unformatted " " + gl.des.
        put stream m-out unformatted
            "<br>" skip
            "НА " v-dt  "<br>" skip.
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
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Остаток</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Остаток_KZT</td>"
                  "</tr>" skip.
    end.
    if first-of(wrk.lcprod) then do:
        assign v-ost = 0 v-ost = 0.
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
              "<td>" wrk.crc_code "</td>"
              "<td>" replace(trim(string(wrk.ost,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "<td>" replace(trim(string(wrk.ost_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "</tr>" skip.

    v-ost = v-ost + wrk.ost_KZT.
    /*v-tcam = v-tcam + wrk.cam_KZT.
    v-tdam_all = v-tdam_all + wrk.dam_KZT.*/
    v-ost_all = v-ost_all + wrk.ost_KZT.

    if last-of(wrk.lcprod) then do:
        put stream m-out unformatted
              "<tr>"
              "<td>" wrk.lcprod "</td>"
              "<td colspan=5>ИТОГО ОСТАТКИ ПО ПРОДУКТУ </td>"
              "<td>" replace(trim(string(v-ost,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "</tr>" skip.

    end.
    if last-of(wrk.gl) then do:
        put stream m-out unformatted
              "<tr>"
              "<td colspan=6>ВСЕГО </td>"
              "<td>" replace(trim(string(v-ost_all,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
              "</tr>" skip.
        put stream m-out unformatted "</table><br>" skip.

    end.
end.

output stream m-out close.
unix silent cptwin lcrep2.htm excel.
