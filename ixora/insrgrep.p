/* insrgrep.p
 * MODULE
      Клиенты и счета   
 * DESCRIPTION
      Отчет по реестру РПРО
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        08/12/2009 galina
 * BASES
        BANK COMM
 * CHANGES
 
*/

{global.i}

def var dt1 as date.
def var dt2 as date.
def var v-num as integer.
def var v-mt100in as char.
def var v-exist1 as char.

    form dt1 label ' Укажите период с' format '99/99/9999'
         dt2 label ' по' format '99/99/9999' skip(1)
         v-num label ' Номер реестра' format ">>>>>>>>>9"
    with side-label row 5 width 48 centered frame dat.
    
    dt2 = today.
    dt1 = date(month(dt2),1,year(dt2)).
    
    update dt1 dt2 v-num with frame dat.
    hide frame dat.
    
    /*********************************************************************************************************************************************************/
    
def temp-table t-rep no-undo
    field dt like insreg.dt
    field num like insreg.num
    field rdt like insreg.rdt
    field rtm as char 
    field regtype as char
    field instype as char
    index num as primary num.
  


message "Формируется отчет.......".
for each insreg where (insreg.rdt le dt2) and (insreg.rdt ge dt1) and ((v-num = 0) or (v-num > 0 and insreg.num = v-num)) no-lock:
  create t-rep.
  assign t-rep.dt = insreg.dt
         t-rep.num = insreg.num
         t-rep.rdt = insreg.rdt
         t-rep.rtm = string(insreg.rtm, "HH:MM:SS")
         t-rep.regtype = insreg.type.
         case t-rep.regtype:
           when 'ACL' then 
               assign t-rep.regtype = t-rep.regtype + ' Реестр расп. о приост. расх. опер. налогопл.'
                      t-rep.instype = 'Распоряжение о налогоплательщике'.
           when 'APL' then
               assign t-rep.regtype = t-rep.regtype + ' Реестр расп. о приост. расх. опер. аг ОПВ'
                      t-rep.instype = 'Распоряжение об агенте ОПВ'.

           when 'ASL' then
               assign t-rep.regtype = t-rep.regtype + ' Реестр расп. о приост. расх. опер. плат. СО'
                      t-rep.instype = 'Распоряжение о плательщике СО'.

         end.
end.

def stream hrep.
output stream hrep to insreport.html.

put stream hrep unformatted
    "<html>" skip
    "<head>" skip
    "<META http-equiv= Content-Type content= text/html; charset= windows-1251>" skip
    "<title>Реестры инкассовых распоряжений</title>" skip
    '<style type="text/css">' skip
        "TABLE \{ " skip
        "border-collapse: collapse; \}" skip
    "</style>" skip
    "</head>" skip
    "<body>" skip
    "<table width= 100% border= 1 cellspacing= 0 cellpadding= 0 valign= top>" skip
    "<tr style= font:bold; font-size:xx-small bgcolor= #C0C0C0 align= center>" skip
    "<td rowspan= 2>Дата и номер<br> реестра</td>" skip
    "<td rowspan= 2>Дата и время принятия реестра</td>" skip
    "<td rowspan= 2>Код формы и заголовок<br> реестра</td>" skip
    "<td rowspan= 2>Тип распоряжения</td></tr><tr></tr>" skip.
 
    for each t-rep no-lock.
    put stream hrep unformatted
    "<tr align= right valign= top cellspacing= 0 cellpadding= 0>" skip
    "<td>" string(t-rep.dt, "99/99/9999") + " " + string(t-rep.num, "999999999") "</td>" skip
    "<td>" string(t-rep.rdt, "99/99/9999") + " " + t-rep.rtm "</td>" skip
    "<td>" t-rep.regtype "</td>" skip
    "<td>" t-rep.instype "</td></tr>" skip.
    end.

    put stream hrep unformatted "</table></body></html>".

    output stream hrep close.
    unix silent cptwin insreport.html iexplore.
    hide all no-pause.