/* apgrsvl.p
 * MODULE
        Финансовая отчетность
 * DESCRIPTION
        отчет по оборотам по ГК с курсовой разницей
 * RUN
        
 * CALLER
        apgrsvl.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        8-2-7
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        23.02.2004 nadejda - переделано на филиалы, выдача в Excel
        25.02.2004 nadejda - выбор филиала вынесен в sel-filial.i
        01.04.2004 nadejda - цикл по филиалам вынесен в r-brfilial.i
*/


{mainhead.i}

def new shared var v-dtb as date.
def new shared var v-dte as date.
def var v-reptyp as integer init 1.
def var v-balin as decimal.
def var v-balout as decimal.
def var v-dam as decimal.
def var v-cam as decimal.
def var v-deltakurs as decimal.


form 
  skip(1)
  v-dtb    label " Начало периода " format "99/99/9999" 
           help " Дата начала отчетного периода"
           validate (v-dtb < g-today, " Дата начала периода должна быть меньше текущей!")
  skip
  v-dte    label "  Конец периода " format "99/99/9999" 
           help " Дата конца отчетного периода"
           validate (v-dtb <= v-dte, " Дата конца периода должна быть не меньше даты начала!")
  skip(1)
  v-reptyp label " 1) полный отчет 2) сокращенный отчет " format "9" 
           help " Вид отчета - с разбивкой по валютам и счетам или сокращенный"
           validate (v-reptyp >= 1 and v-reptyp <= 2, " Неверный выбор вида отчета!")
  " " skip(1)
  with centered row 5 side-label title " ПАРАМЕТРЫ ОТЧЕТА " frame f-param.

find last cls no-lock no-error.
v-dtb = cls.whn.
v-dte = cls.whn.
displ v-dtb v-dte v-reptyp with frame f-param.

update v-dtb with frame f-param.
update v-dte v-reptyp with frame f-param.

def new shared temp-table t-data
  field gl as integer
  field balin as decimal extent 30
  field balout as decimal extent 30
  field balinkzt as decimal extent 30
  field baloutkzt as decimal extent 30
  field dam as decimal extent 30
  field cam as decimal extent 30
  field damkzt as decimal extent 30
  field camkzt as decimal extent 30
  field deltakurs as decimal extent 30
  index gl is primary unique gl.


{r-brfilial.i &proc = "apgrsvldat (txb.bank)"}


/*  01.01.2004 nadejda

{sel-filial.i}

if not connected ("comm") then run comm-con.

for each comm.txb where comm.txb.consolid = true and (if v-select = 1 then true else comm.txb.txb = v-select - 2) no-lock:
    if connected ("ast") then disconnect "ast".
    connect value(" -db " + comm.txb.path + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password). 
    run apgrsvldat (comm.txb.bank).
end.
    
if connected ("ast")  then disconnect "ast".
*/

/* расчет курсовой разницы */
for each t-data:
  for each crc where crc.crc > 1 no-lock:
    t-data.deltakurs[crc.crc] = t-data.baloutkzt[crc.crc] - t-data.balinkzt[crc.crc].
    if t-data.dam[crc.crc] <> 0 or t-data.cam[crc.crc] <> 0 then do:
      find gl where gl.gl = t-data.gl no-lock no-error.
      if lookup(gl.type, "a,e") > 0 then t-data.deltakurs[crc.crc] = t-data.deltakurs[crc.crc] - (t-data.damkzt[crc.crc] - t-data.camkzt[crc.crc]).
                                    else t-data.deltakurs[crc.crc] = t-data.deltakurs[crc.crc] - (t-data.camkzt[crc.crc] - t-data.damkzt[crc.crc]).
    end.
  end.
end.



def stream rep.
output stream rep to repgl.html.

{html-title.i &stream = "stream rep" &size-add = "x-"}

put stream rep unformatted
  "<p><b>Отчет по оборотам по счетам ГК с курсовой разницей<br><br>"
    "за период с " v-dtb " по " v-dte "г.<br>"
    v-bankname "</b></p>" skip
  "<table border=1 cellspacing=0 cellpadding=0>" skip
    "<tr style=""font:bold"">" skip
      "<td>Счет ГК</td>" skip
      "<td>Наименование</td>" skip
      "<td>Вход.остаток</td>" skip
      "<td>Обороты дебет</td>" skip
      "<td>Обороты кредит</td>" skip
      "<td>Исход.остаток</td>" skip
      "<td>Курс.разница</td>" skip
    "</tr>" skip.


case v-reptyp :
  when 1 then do:  /* полный отчет */
    for each crc no-lock:
      find first t-data where t-data.balin[crc.crc] <> 0 or 
                              t-data.balout[crc.crc] <> 0 or 
                              t-data.dam[crc.crc] <> 0 or
                              t-data.cam[crc.crc] <> 0 or
                              t-data.deltakurs[crc.crc] <> 0 no-lock no-error.
      if not avail t-data then next.

      put stream rep unformatted
        "<tr><td></td><td></td></tr><tr style=""font:bold""><td>ВАЛЮТА :</td><td>" crc.des "</td></tr>" skip.

      for each t-data:
        find gl where gl.gl = t-data.gl no-lock no-error.
        put stream rep unformatted
           "<tr><td>" t-data.gl "</td>" skip
             "<td>" gl.des "</td>" skip
             "<td>" replace(trim(string(t-data.balin[crc.crc], "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
             "<td>" replace(trim(string(t-data.dam[crc.crc], "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
             "<td>" replace(trim(string(t-data.cam[crc.crc], "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
             "<td>" replace(trim(string(t-data.balout[crc.crc], "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
             "<td></td>" skip
             "</tr>" skip.

        if crc.crc > 1 then do:
          put stream rep unformatted
             "<tr><td></td>" skip
               "<td></td>" skip
               "<td>" replace(trim(string(t-data.balinkzt[crc.crc], "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
               "<td>" replace(trim(string(t-data.damkzt[crc.crc], "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
               "<td>" replace(trim(string(t-data.camkzt[crc.crc], "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
               "<td>" replace(trim(string(t-data.baloutkzt[crc.crc], "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
               "<td>" replace(trim(string(t-data.deltakurs[crc.crc], "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
               "</tr>" skip.
        end.
      end.
    end.
  end.

  when 2 then do:  /* сокращенный отчет */
    for each t-data :

      v-balin = t-data.balin[1].
      v-balout = t-data.balout[1].
      v-dam = t-data.dam[1].
      v-cam = t-data.cam[1].

      for each crc where crc.crc > 1 no-lock:
        v-balin = v-balin + t-data.balinkzt[crc.crc].
        v-balout = v-balout + t-data.baloutkzt[crc.crc].
        v-dam = v-dam + t-data.dam[crc.crc].
        v-cam = v-cam + t-data.cam[crc.crc].
      end.

      find gl where gl.gl = t-data.gl no-lock no-error.

      v-deltakurs = v-balout - v-balin.
      if v-dam <> 0 or v-cam <> 0 then do:
        if lookup(gl.type, "a,e") > 0 then v-deltakurs = v-deltakurs - (v-dam - v-cam).
                                      else v-deltakurs = v-deltakurs - (v-cam - v-dam).
      end.
      
      put stream rep unformatted
         "<tr><td>" t-data.gl "</td>" skip
           "<td>" gl.des "</td>" skip
           "<td>" replace(trim(string(v-balin, "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
           "<td>" replace(trim(string(v-dam, "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
           "<td>" replace(trim(string(v-cam, "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
           "<td>" replace(trim(string(v-balout, "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
           "<td>" replace(trim(string(v-deltakurs, "->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
           "</tr>" skip.
    end.
  end.
end case.

put stream rep unformatted "</table>" skip.

{html-end.i "stream rep"}

output stream rep close.
unix silent cptwin repgl.html excel.
pause 0.


