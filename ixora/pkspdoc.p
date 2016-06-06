/* pkspdoc.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Печать описи документов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        17.11.2003 marinav
 * CHANGES
        25.11.2003 marinav - исправление ошибок
        19/11/2004 madiyar - добавил 6 документов по БД
        23/11/2004 sasco поменял 081 на 089
        25/03/2005 madiyar - добавил 2 документа по БД (только в головном)
        23/06/2005 madiyar - добавил 1 документ, убрал 3 документа (только в головном)
        28/06/2005 madiyar - убрал 1 документ, 3 документа (согласия) объединил в одну строчку
        27/10/2005 madiyar - убрал 3 документа на филиалах
        20/01/2006 madiyar - убрал согласие на запрос в ЦИС
        06/02/2006 madiyar - небольшие изменения для Актобе
        11/08/2006 madiyar - добавил отчет АИСТ
        25/08/2006 madiyar - добавил документ о прописке, убрал колонку с номерами страниц
        10/04/07 marinav - приложение 1
        28/04/2007 madiyar - web-анкета
        22/06/2007 madiyar - добавил новые документы
        02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
        18/07/2007 madiyar - изменение по тексту
        19/07/2007 madiyar - изменение по тексту (вместо "Копия заявления в бухгалтерию..." - "Заявление в бухгалтерию...")
        12/03/2008 madiyar - микрокредит -> кредит
        04/06/2009 madiyar - изменения по тексту, "копия договора" и "копия приложения"
        14/12/2009 galina - изменила список документов согласно ТЗ 596 от 14/12/2009
        20/12/2009 galina - исправила ошибку в тексте
        28/12/2009 galina - исправила текст
*/


{global.i}
{pk.i}
{pk-sysc.i}
{sysc.i}

/*s-credtype = '6'.
s-pkankln = 5978.
*/
define var v-sumq0 as deci.
define var nn as inte init 1.
def buffer b-pkanketa for pkanketa.
def buffer b-pkanketh for pkanketh.

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

find lon where lon.lon = pkanketa.lon no-lock no-error.
if not avail lon then do:
  if pkanketa.id_org <> "inet" then message skip " Ссудный счет N" pkanketa.lon "не найден !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = pkanketa.ln and b-pkanketh.kritcod = "subln" no-lock no-error.
if avail b-pkanketh and b-pkanketh.value1 <> '' then find b-pkanketa where b-pkanketa.bank = s-ourbank and b-pkanketa.credtype = s-credtype and b-pkanketa.ln = int(b-pkanketh.value1) no-lock no-error.
find first crc where crc.crc = pkanketa.crc no-lock no-error.
find first cmp no-lock no-error.

define stream v-out.
output stream v-out to opis.html.

put stream v-out unformatted
                 "<!-- Опись документов -->" skip
                 "<html><head><title>ТОО ""МКО ""НАРОДНЫЙ КРЕДИТ""</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"
                 "<STYLE TYPE=""text/css"">" skip
                 "body, H4, H3 ~{margin-top:0pt; margin-bottom:0pt~}" skip
                 "</STYLE></head><body>" skip.

put stream v-out unformatted "<table WIDTH=600 border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">".
put stream v-out unformatted "<tr align=""center""><td><h3>" cmp.name format 'x(79)' "</h3></td></tr><tr></tr><tr></tr>".
put stream v-out unformatted "<tr align=""center""><td><h3> КЛИЕНТ " pkanketa.name format "x(60)" "</h3></td></tr>".
if avail b-pkanketa then put stream v-out unformatted "<tr align=""center""><td><h3> СОЗАЕМЩИК " b-pkanketa.name format "x(60)" "</h3></td></tr>".

put stream v-out unformatted "<tr align=""center""><td><h3> Опись документов кредитного досье N " s-pkankln
                " согласно Договору N "
                 entry(1,pkanketa.rescha[1]) " от " pkanketa.docdt    "</h3></td></tr><BR>".

       put stream v-out unformatted "<tr><td><table width=""100%""border=""1"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">".
       if not avail b-pkanketa then put stream v-out unformatted "<tr align=""center""  bgcolor=""#C0C0C0"" style=""font:bold"">"
           "<td>П/п</td>"
           "<td>Наименование</td>" skip
           "<td>Стр.*</td></tr>" skip.
           
           /*для созаемщика*/
       if avail b-pkanketa then do:    
           put stream v-out unformatted
           "<tr align=""center""  bgcolor=""#C0C0C0"" style=""font:bold"">"
           "<td rowspan = ""2"">П/п</td>"
           "<td>Наименование</td>" skip
            "<td rowspan = ""2"">Стр.*</td></tr>" skip
           "<tr align=""center""  bgcolor=""#C0C0C0"" style=""font:bold"">"
           "<td>Документы по Созаемщику:</td></tr>" skip.

            put stream v-out unformatted "<tr><td>" nn "</td>"
                   "<td>Заявка-анкета на получение кредита от " b-pkanketa.rdt "</td><td></td></tr>" skip.
    
            find b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "dtpas" no-lock no-error.
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td>"
                   "<td> Копия удостоверения личности N " b-pkanketa.docnum " от " date(b-pkanketh.value1) "</td><td></td></tr>" skip.
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td>"
                   "<td> Копия СИКа </td><td></td></tr>" skip.
            nn = nn + 1.
    
            put stream v-out unformatted "<tr><td>" nn "</td>"
                   "<td> Копия РНН N " b-pkanketa.rnn "</td><td></td></tr>" skip.
              nn = nn + 1.
    
            put stream v-out unformatted "<tr><td>" nn "</td>"
             "<td> Документ, подтверждающий прописку</td><td></td></tr>" skip.
    
            
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td>"
                   "<td>Заявление в ГЦВП от " b-pkanketa.rdt "</td><td></td></tr>" skip.
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td>"
                   "<td> Выписка из ГЦВП "  "</td><td></td></tr>" skip.
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td>"
                   "<td>Выписка из пенсионного фонда</td><td></td></tr>" skip.
            nn = nn + 1.       
            put stream v-out unformatted "<tr><td>" nn "</td><td>Согласие ЦИС</td><td></td></tr>" skip.               
    
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td><td>Отчет по запросу в ЦИС</td><td></td></tr>" skip.
     
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td><td>Отчет АИСТ</td><td></td></tr>" skip.
    
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td><td>Служебная записка</td><td></td></tr>" skip.
    
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td><td>Служебная записка ДМ и ВК/ОМ и ВК филиала</td><td></td></tr>" skip.
    
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td><td>Кредитный скоринг</td><td></td></tr>" skip.
    
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td><td>Согласие субъекта кредитной истории на предоставление информации о нем в КБ</td><td></td></tr>" skip.
            
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td><td>Согласие субъекта кредитной истории на получение информации о нем из КБ</td><td></td></tr>" skip.
            
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td><td>Отчет из Кредитного бюро</td><td></td></tr>" skip.
    
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td><td>Согласие</td><td></td></tr>" skip.
    
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td><td> Заявление в бухгалтерию клиента от " pkanketa.docdt "</td><td></td></tr>" skip.
            
            nn = nn + 1.
            put stream v-out unformatted "<tr><td>" nn "</td><td> Документ с образцом подписи</td><td></td></tr>" skip.    
            nn = nn + 1.
       end.

       /**************Заемщик*****************/
       if avail b-pkanketa then put stream v-out unformatted
           "<tr align=""center""  bgcolor=""#C0C0C0"" style=""font:bold"">"
           "<td></td>"
           "<td>Документы по Заемщику</td><td></td></tr>" skip.
        put stream v-out unformatted "<tr><td>" nn "</td>"
               "<td>Заявка-анкета на получение кредита от " pkanketa.rdt "</td><td></td></tr>" skip.
        
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td> Операционный ордер за рассмотрение заявки по рефинансированию</td><td></td></tr>" skip.    

        find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "dtpas" no-lock no-error.
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td>"
               "<td> Копия удостоверения личности N " pkanketa.docnum " от " date(pkanketh.value1) "</td><td></td></tr>" skip.
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td>"
               "<td> Копия СИКа </td><td></td></tr>" skip.
        nn = nn + 1.

        put stream v-out unformatted "<tr><td>" nn "</td>"
               "<td> Копия РНН N " pkanketa.rnn "</td><td></td></tr>" skip.
    
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td>"
               "<td> Документ, подтверждающий прописку</td><td></td></tr>" skip.

  
  
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td>"
               "<td>Заявление в ГЦВП от " pkanketa.rdt "</td><td></td></tr>" skip.
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td>"
               "<td> Выписка из ГЦВП "  "</td><td></td></tr>" skip.
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td>"
               "<td>Выписка из пенсионного фонда</td><td></td></tr>" skip.
        nn = nn + 1.       
        put stream v-out unformatted "<tr><td>" nn "</td><td>Согласие ЦИС</td><td></td></tr>" skip.               
        
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td>Отчет по запросу в ЦИС</td><td></td></tr>" skip.
        
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td>Отчет АИСТ</td><td></td></tr>" skip.
        
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td>Служебная записка</td><td></td></tr>" skip.
    
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td>Служебная записка ДМ и ВК/ОМ и ВК филиала</td><td></td></tr>" skip.
    
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td>Кредитный скоринг</td><td></td></tr>" skip.
    
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td>Согласие субъекта кредитной истории на предоставление информации о нем в КБ</td><td></td></tr>" skip.
            
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td>Согласие субъекта кредитной истории на получение информации о нем из КБ</td><td></td></tr>" skip.
            
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td>Отчет из Кредитного бюро</td><td></td></tr>" skip.
            
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td>Согласие</td><td></td></tr>" skip.

        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td>Решение Кредитного Комитета</td><td></td></tr>" skip.
   
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td> Заявление в бухгалтерию клиента от " pkanketa.docdt "</td><td></td></tr>" skip.
        
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td> Документ с образцом подписи</td><td></td></tr>" skip.    

        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td><td> Договор банковского счета</td><td></td></tr>" skip.    
        
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td>"
               "<td> Копия Договора N " entry(1,pkanketa.rescha[1]) format 'x(15)' " о предоставлении потребительского кредита от " pkanketa.docdt "</td><td></td></tr>" skip.

        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td>"
               "<td> Копия Приложения N 1 к договору о предоставлении кредита</td><td></td></tr>" skip.

        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td>"
               "<td> Операционный ордер N " pkanketa.trx1 format ">>>>>>>>>>" "</td><td></td></tr>" skip.
        nn = nn + 1.
        put stream v-out unformatted "<tr><td>" nn "</td>"
               "<td> Операционный ордер за снятие комиссии N " pkanketa.trx2 format ">>>>>>>>>>" "</td><td></td></tr>" skip.


put stream v-out unformatted "</table><BR><BR>".
put stream v-out unformatted "* Нумерация страниц производится в верхнем правом углу листа".
output stream v-out close.

if pkanketa.id_org = "inet" then unix silent value("mv opis.html /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/opis.html").
else unix silent cptwin opis.html excel.
