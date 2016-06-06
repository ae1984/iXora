/* lnrn.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Управленческий отчет по кредитному портфелю
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        21/07/2009 madiyar - скопировал из lnaudit.p с изменениями
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}
def new shared var d as date no-undo extent 2.
def var cntsum as decimal no-undo extent 10.
def new shared var v-reptype as integer no-undo.
v-reptype = 1.

def var v-sum as deci no-undo extent 10.

def new shared temp-table wrk1 no-undo
  field rep_id as int
  field id as int
  field gr as char
  field kol as int
  field od as deci /* ОД */
  field odp as deci /* просроченный ОД */
  field nachprc as deci /* начисленные проценты в тенге */
  field polprc as deci /* полученные проценты в тенге */
  field prosrprc as deci /* просроченные проценты в тенге */
  field nachprcz as deci /* начисленные вне баланса проценты в тенге */
  field pen as deci /* штрафы */
  field penz as deci /* штрафы вне баланса */
  field polpen as deci /* полученные штрафы */
  index idx is primary rep_id id.

def temp-table t no-undo
  field cat1 as int
  field cat2 as int
  field kol as int
  field od as deci /* ОД */
  field odp as deci /* просроченный ОД */
  field nachprc as deci /* начисленные проценты в тенге */
  field polprc as deci /* полученные проценты в тенге */
  field prosrprc as deci /* просроченные проценты в тенге */
  field nachprcz as deci /* начисленные вне баланса проценты в тенге */
  field pen as deci /* штрафы */
  field penz as deci /* штрафы вне баланса */
  field polpen as deci /* полученные штрафы */
  index idx is primary cat1 cat2.

def temp-table t-cats no-undo
  field id as int
  field des as char
  index idx is primary id.

def new shared temp-table wrk no-undo
    field d as integer
    field bank as char
    field gl like lon.gl
    field name as char
    field cif like lon.cif
    field lon like lon.lon
    field grp like lon.grp
    field bankn as char
    field crc like crc.crc
    field rdt like lon.rdt
    field duedt like lon.duedt
    field opnamt as deci
    field opnamt_kzt as deci
    field ostatok as deci
    field prosr_od as deci

    field dayc_od as int
    field fdayc_od as int
    field fdayc_od2 as int

    field cat as int

    field ostatok_kzt as deci
    field prosr_od_kzt as deci
    field prem as deci
    field nach_prc as deci
    field pol_prc as deci
    field prosr_prc as deci

    field dayc_prc as int
    field fdayc_prc as int

    field nach_prc_kzt as deci
    field pol_prc_kzt as deci
    field prosr_prc_kzt as deci
    field prosr_prc_zabal as deci
    field prosr_prc_zab_kzt as deci
    field penalty as deci
    field penalty_zabal as deci
    field penalty_pol as deci

    field processed as logi init no

    index ind is primary d bank cif lon
    index ind2 d processed.

def buffer b-wrk for wrk.

def var i as integer no-undo.

do i = 1 to 2:
    create wrk1.
    wrk1.rep_id = i.
    wrk1.id = 1.
    wrk1.gr = "Без просрочки".
    create wrk1.
    wrk1.rep_id = i.
    wrk1.id = 2.
    wrk1.gr = "До 30 дней".
    create wrk1.
    wrk1.rep_id = i.
    wrk1.id = 3.
    wrk1.gr = "31 - 60 дней".
    create wrk1.
    wrk1.rep_id = i.
    wrk1.id = 4.
    wrk1.gr = "61 - 90 дней".
    create wrk1.
    wrk1.rep_id = i.
    wrk1.id = 5.
    wrk1.gr = "91 - 180 дней".
    create wrk1.
    wrk1.rep_id = i.
    wrk1.id = 6.
    wrk1.gr = "181 - 360 дней".
    create wrk1.
    wrk1.rep_id = i.
    wrk1.id = 7.
    wrk1.gr = "> 360 дней".
end.

for each wrk1 where wrk1.rep_id = 1 no-lock:
    create t-cats.
    assign t-cats.id = wrk1.id
           t-cats.des = wrk1.gr.
end.

create t-cats.
assign t-cats.id = -2
       t-cats.des = "Новые кредиты".
create t-cats.
assign t-cats.id = -1
       t-cats.des = "Полное погашение".
create t-cats.
assign t-cats.id = 0
       t-cats.des = "Частичное погашение".

d[1] = g-today - 1.
d[2] = g-today.
update d[1] label ' Дата1' format '99/99/9999' validate (d[1] <= g-today, " Дата должна быть не позже текущей!") skip
       d[2] label ' Дата2' format '99/99/9999' validate (d[2] <= g-today, " Дата должна быть не позже текущей!") skip
       v-reptype label ' Вид отчета' format "9" validate ( v-reptype > 0 and v-reptype < 5, " Тип отчета - 1, 2, 3 или 4") help "1 - Юр, 2 - Физ, 3 - БД, 4 - все"
       skip with side-labels row 5 centered frame dat.

{r-brfilial.i &proc = "lnrns1"}

def stream m-out.
output stream m-out to rep.htm.
put stream m-out unformatted "<html><head><title>METROCOMBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted
      "<br>" v-bankname "<br>" skip
      "&nbsp;" + string(d[1],"99/99/9999") + "<br>" skip
      "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
      "<tr style=""font:bold"">"
      "<td bgcolor=""#C0C0C0"" align=""center""></td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">ОД</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Просроч. ОД</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %%</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Получ. %%</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Просроч. %%</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %% вне баланса</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы вне баланса</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Получ. штрафы</td>"
      "</tr>" skip.

v-sum = 0.
for each wrk1 where wrk1.rep_id = 1 no-lock:
    put stream m-out unformatted
          "<tr>"
          "<td>" wrk1.gr "</td>" skip
          "<td>" wrk1.kol "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.odp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.nachprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.polprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.prosrprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.nachprcz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.pen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.penz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.polpen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "</tr>" skip.
    v-sum[1] = v-sum[1] + wrk1.kol.
    v-sum[2] = v-sum[2] + wrk1.od.
    v-sum[3] = v-sum[3] + wrk1.odp.
    v-sum[4] = v-sum[4] + wrk1.nachprc.
    v-sum[5] = v-sum[5] + wrk1.polprc.
    v-sum[6] = v-sum[6] + wrk1.prosrprc.
    v-sum[7] = v-sum[7] + wrk1.nachprcz.
    v-sum[8] = v-sum[8] + wrk1.pen.
    v-sum[9] = v-sum[9] + wrk1.penz.
    v-sum[10] = v-sum[10] + wrk1.polpen.
end.

put stream m-out unformatted
      "<tr style=""font:bold"">"
      "<td></td>" skip
      "<td>" v-sum[1] "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[4],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[5],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[6],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[7],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[8],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[9],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[10],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "</tr>" skip.

put stream m-out unformatted "</table>".

put stream m-out unformatted
      "<br>" skip
      "&nbsp;" + string(d[2],"99/99/9999") + "<br>" skip
      "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
      "<tr style=""font:bold"">"
      "<td bgcolor=""#C0C0C0"" align=""center""></td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">ОД</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Просроч. ОД</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %%</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Получ. %%</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Просроч. %%</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %% вне баланса</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы вне баланса</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Получ. штрафы</td>"
      "</tr>" skip.

v-sum = 0.
for each wrk1 where wrk1.rep_id = 2 no-lock:
    put stream m-out unformatted
          "<tr>"
          "<td>" wrk1.gr "</td>" skip
          "<td>" wrk1.kol "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.odp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.nachprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.polprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.prosrprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.nachprcz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.pen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.penz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(wrk1.polpen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "</tr>" skip.
    v-sum[1] = v-sum[1] + wrk1.kol.
    v-sum[2] = v-sum[2] + wrk1.od.
    v-sum[3] = v-sum[3] + wrk1.odp.
    v-sum[4] = v-sum[4] + wrk1.nachprc.
    v-sum[5] = v-sum[5] + wrk1.polprc.
    v-sum[6] = v-sum[6] + wrk1.prosrprc.
    v-sum[7] = v-sum[7] + wrk1.nachprcz.
    v-sum[8] = v-sum[8] + wrk1.pen.
    v-sum[9] = v-sum[9] + wrk1.penz.
    v-sum[10] = v-sum[10] + wrk1.polpen.
end.

put stream m-out unformatted
      "<tr style=""font:bold"">"
      "<td></td>" skip
      "<td>" v-sum[1] "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[4],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[5],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[6],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[7],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[8],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[9],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td align=""right"">" replace(trim(string(v-sum[10],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "</tr>" skip.

put stream m-out unformatted "</table>".


for each wrk where wrk.d = 1 no-lock:
    find first b-wrk where b-wrk.d = 2 and b-wrk.bank = wrk.bank and b-wrk.cif = wrk.cif and b-wrk.lon = wrk.lon exclusive-lock no-error.
    if avail b-wrk then do:
        b-wrk.processed = yes.
        find first t where t.cat1 = wrk.cat and t.cat2 = b-wrk.cat exclusive-lock no-error.
        if not avail t then do:
            create t.
            assign t.cat1 = wrk.cat
                   t.cat2 = b-wrk.cat.
        end.
        assign t.kol = t.kol + 1
               t.od = t.od + b-wrk.ostatok_kzt
               t.odp = t.odp + b-wrk.prosr_od_kzt
               t.nachprc = t.nachprc + b-wrk.nach_prc_kzt
               t.polprc = t.polprc + b-wrk.pol_prc_kzt
               t.prosrprc = t.prosrprc + b-wrk.prosr_prc_kzt
               t.nachprcz = t.nachprcz + b-wrk.prosr_prc_zab_kzt
               t.pen = t.pen + b-wrk.penalty
               t.penz = t.penz + b-wrk.penalty_zabal
               t.polpen = t.polpen + b-wrk.penalty_pol.
        /* частичное погашение */
        if (b-wrk.ostatok_kzt < wrk.ostatok_kzt) or
           (b-wrk.prosr_od_kzt < wrk.prosr_od_kzt) or
           (b-wrk.nach_prc_kzt < wrk.nach_prc_kzt) or
           (b-wrk.pol_prc_kzt < wrk.pol_prc_kzt) or
           (b-wrk.prosr_prc_kzt < wrk.prosr_prc_kzt) or
           (b-wrk.prosr_prc_zab_kzt < wrk.prosr_prc_zab_kzt) or
           (b-wrk.penalty < wrk.penalty) or
           (b-wrk.penalty_zabal < wrk.penalty_zabal) or
           (b-wrk.penalty_pol < wrk.penalty_pol) then do:
            find first t where t.cat1 = wrk.cat and t.cat2 = 0 exclusive-lock no-error.
            if not avail t then do:
                create t.
                assign t.cat1 = wrk.cat
                       t.cat2 = 0.
            end.
            t.kol = t.kol + 1.
            if (b-wrk.ostatok_kzt < wrk.ostatok_kzt) then t.od = t.od + (wrk.ostatok_kzt - b-wrk.ostatok_kzt).
            if (b-wrk.prosr_od_kzt < wrk.prosr_od_kzt) then t.odp = t.odp + (wrk.prosr_od_kzt - b-wrk.prosr_od_kzt).
            if (b-wrk.nach_prc_kzt < wrk.nach_prc_kzt) then t.nachprc = t.nachprc + (wrk.nach_prc_kzt - b-wrk.nach_prc_kzt).
            if (b-wrk.pol_prc_kzt < wrk.pol_prc_kzt) then t.polprc = t.polprc + (wrk.pol_prc_kzt - b-wrk.pol_prc_kzt).
            if (b-wrk.prosr_prc_kzt < wrk.prosr_prc_kzt) then t.prosrprc = t.prosrprc + (wrk.prosr_prc_kzt - b-wrk.prosr_prc_kzt).
            if (b-wrk.prosr_prc_zab_kzt < wrk.prosr_prc_zab_kzt) then t.prosrprc = t.prosrprc + (wrk.prosr_prc_zab_kzt - b-wrk.prosr_prc_zab_kzt).
            if (b-wrk.penalty < wrk.penalty) then t.pen = t.pen + (wrk.penalty - b-wrk.penalty).
            if (b-wrk.penalty_zabal < wrk.penalty_zabal) then t.penz = t.penz + (wrk.penalty_zabal - b-wrk.penalty_zabal).
            if (b-wrk.penalty_pol < wrk.penalty_pol) then t.polpen = t.polpen + (wrk.penalty_pol - b-wrk.penalty_pol).
        end.
    end.
    else do:
        /* полное погашение */
        find first t where t.cat1 = wrk.cat and t.cat2 = -1 exclusive-lock no-error.
        if not avail t then do:
            create t.
            assign t.cat1 = wrk.cat
                   t.cat2 = -1.
        end.
        assign t.kol = t.kol + 1
               t.od = t.od + wrk.ostatok_kzt
               t.odp = t.odp + wrk.prosr_od_kzt
               t.nachprc = t.nachprc + wrk.nach_prc_kzt
               t.polprc = t.polprc + wrk.pol_prc_kzt
               t.prosrprc = t.prosrprc + wrk.prosr_prc_kzt
               t.nachprcz = t.nachprcz + wrk.prosr_prc_zab_kzt
               t.pen = t.pen + wrk.penalty
               t.penz = t.penz + wrk.penalty_zabal
               t.polpen = t.polpen + wrk.penalty_pol.
    end.
end.

/* свежевыданные */
for each wrk where wrk.d = 2 and (not wrk.processed) no-lock:
    find first t where t.cat1 = -2 and t.cat2 = wrk.cat exclusive-lock no-error.
    if not avail t then do:
        create t.
        assign t.cat1 = -2
               t.cat2 = wrk.cat.
    end.
    assign t.kol = t.kol + 1
           t.od = t.od + wrk.ostatok_kzt
           t.odp = t.odp + wrk.prosr_od_kzt
           t.nachprc = t.nachprc + wrk.nach_prc_kzt
           t.polprc = t.polprc + wrk.pol_prc_kzt
           t.prosrprc = t.prosrprc + wrk.prosr_prc_kzt
           t.nachprcz = t.nachprcz + wrk.prosr_prc_zab_kzt
           t.pen = t.pen + wrk.penalty
           t.penz = t.penz + wrk.penalty_zabal
           t.polpen = t.polpen + wrk.penalty_pol.
end.

put stream m-out unformatted
      "&nbsp;<br>&nbsp;Миграция<br>" skip
      "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
      "<tr style=""font:bold"">"
      "<td bgcolor=""#C0C0C0"" align=""center"">Исх. категория</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Кон. категория</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">ОД</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Просроч. ОД</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %%</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Получ. %%</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Просроч. %%</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %% вне баланса</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы вне баланса</td>"
      "<td bgcolor=""#C0C0C0"" align=""center"">Получ. штрафы</td>"
      "</tr>" skip.

for each t no-lock break by t.cat1 by t.cat2:
    put stream m-out unformatted "<tr>" skip.
    if first-of(t.cat1) then do:
        find first t-cats where t-cats.id = t.cat1 no-lock no-error.
        if avail t-cats then put stream m-out unformatted "<td>" t-cats.des "</td>" skip.
        else put stream m-out unformatted "<td>NOT FOUND</td>" skip.
    end.
    else put stream m-out unformatted "<td></td>" skip.
    find first t-cats where t-cats.id = t.cat2 no-lock no-error.
    if avail t-cats then put stream m-out unformatted "<td>" t-cats.des "</td>" skip.
    else put stream m-out unformatted "<td>NOT FOUND</td>" skip.
    put stream m-out unformatted
          "<td>" t.kol "</td>" skip
          "<td align=""right"">" replace(trim(string(t.od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(t.odp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(t.nachprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(t.polprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(t.prosrprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(t.nachprcz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(t.pen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(t.penz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td align=""right"">" replace(trim(string(t.polpen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "</tr>" skip.
end.

put stream m-out unformatted "</table></body></html>" skip.
output stream m-out close.

unix silent cptwin rep.htm excel.

