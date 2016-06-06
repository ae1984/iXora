/* kddoc.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Печать списков документов для потенциальных заемщиков
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
        01.08.03 marinav 
 * CHANGES
        07.01.04 marinav - изменения по тексту
        06/07/04 madiar  - изменения по тексту
        25/08/04 sasco   - теперь список документов залогодателя печатается по списку в таблице kddocs
        22/10/04 madiar  - добавил три новых документа (после Заявления-анкеты)
        15/03/05 madiar  - добавил абзац в начале документа
        24/05/05 madiar  - убрал "Обязательство субъекта кредитной истории"
      30.09.2005 marinav - изменения для бизнес-кредитов
*/

{global.i}

def var v-zal   as char format "x(20)".
def var v-sel as char.
def var prz_bk as char.
def var prz_k as inte.
def var prz_z as char.
def var v-ofc as char.
def var v-datastr as char.
def var v-datastrkz as char no-undo.

def button  btn1  label "    Физическое лицо    ".
def button  btn2  label "    Юридическое лицо   ".
def button  btn3  label "    ЧП          ".
def button  btn4  label "    Выход        ".

def var v-ofile as char.  
v-ofile = "kddoc.htm".

  run sel ("ЗАЕМЩИК :", 
           " 1. Юридическое лицо - Кредит   | 2. Юридическое лицо - БизнесКредит  | 3. Физическое лицо  - БизнесКредит | 4. ЧП               - БизнесКредит | 5. Выход ").
  v-sel = return-value.

  case v-sel:     

    when "1" then  assign prz_bk = '01' prz_k = 0.
    when "2" then  assign prz_bk = '02' prz_k = 0.
    when "3" then  assign prz_bk = '02' prz_k = 1.
    when "4" then  assign prz_bk = '02' prz_k = 2.
    when "5" then return.
  end case.

  run sel ("ЗАЛОГОДАТЕЛЬ :", 
           " 1. Юридическое лицо    | 2. Физическое лицо  | 3. ЧП  | 4. Выход ").
  v-sel = return-value.

  case v-sel:     

    when "1" then  assign prz_z = '0'.
    when "2" then  assign prz_z = '1'.
    when "3" then  assign prz_z = '2'.
    when "4" then return.
  end case.

run uni_book ("zalog", "", output v-zal).
v-zal = v-zal + ',00,10'.
prz_z = prz_z + ',3,4'.


def stream v-out.
output stream v-out to value(v-ofile).



{html-title.i 
 &stream = " stream v-out "
 &title = " ДОКУМЕНТЫ ЗАЕМЩИКА "
 &size-add = "xx-"
}

put stream v-out unformatted 
"<TABLE width=""98%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"" style=""font-size:8pt"">" skip
"<TR><TD><TABLE width=""95%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
  "<TD align=""right""><img src=""http://www.texakabank.kz/images/top_logo_bw.gif""></TD>" skip
  "</TR></TABLE></TD></TR>" skip
"<TR><TD><BR><BR>" skip
  "<P align=""justify"">" skip

  "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"" style=""font-size:8pt"">" skip
    "<TR><TD align=""center"" ><B>" skip
    "ПЕРЕЧЕНЬ ОСНОВНЫХ ДОКУМЕНТОВ, НЕОБХОДИМЫХ ДЛЯ ЭКСПЕРТИЗЫ ПРОЕКТА.<BR>&nbsp;</B></TD></TR>"
    
    "<TR><TD align=""left""><B>" skip
    "Обращаем внимание, что финансирование предоставляется в течение 2-х рабочих дней при выполнении следующих условий:" skip
    " <ul style='margin-top:0cm; font-size:8pt' type=disc>" skip
    "  <li> положительное решение Кредитного комитета АО ""TEXAKABANK"";</li>" skip
    "  <li> предоставление всех документов (полное формирование кредитного досье) в соответствии с нижеприведенным перечнем, а также требованиями законодательства РК;</li>" skip
    "  <li> устранение всех выявленных в процессе экспертизы проекта замечаний.</li>" skip
    " </ul>" skip
    "</B></TD></TR>" skip
    
  "</TABLE><BR>" skip.

    put stream v-out unformatted  skip
          "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
            "<TR align=""center"" style=""font:bold;font-size:xx-small"">" skip
              "<TD width=""10%"">ОТМЕТКА</TD>" skip
              "<TD width=""60%"">ДОКУМЕНТЫ ЗАЕМЩИКА</TD>" skip
              "<TD width=""30%"">ТРЕБОВАНИЯ К ДОКУМЕНТУ</TD>" skip
          "</TR>" skip.

    for each kddocs where kddocs.ln > 0 and kddocs.kb = prz_bk and kddocs.zaemfu = prz_k and lookup(string(kddocs.fu), prz_z) > 0 and lookup (kddocs.type, v-zal) > 0 no-lock:

    if kddocs.fu = 4 then
    put stream v-out unformatted 
        "<TR><TD></TD>" skip
            "<TD><b>" kddocs.name    "</b></TD>" skip
            "<TD>" kddocs.info[1] "</TD>" skip
        "</TR>" skip.
    else
    put stream v-out unformatted 
        "<TR><TD></TD>" skip
            "<TD>" kddocs.name    "</TD>" skip
            "<TD>" kddocs.info[1] "</TD>" skip
        "</TR>" skip.

    end.


put stream v-out unformatted 
"</table><BR><BR>" skip.

  find ofc where ofc.ofc = g-ofc no-lock no-error.
  v-ofc = entry(1, ofc.name, " ").
  if num-entries(ofc.name, " ") > 1 then v-ofc = v-ofc + " " + substr(entry(2, ofc.name, " "), 1, 1) + ".".
  if num-entries(ofc.name, " ") > 2 then v-ofc = v-ofc + substr(entry(3, ofc.name, " "), 1, 1) + ".".
  run pkdefdtstr (g-today, output v-datastr, output v-datastrkz).

  put stream v-out unformatted 
    "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
    "<TR valign=""top"">"
      "<TD width=""45%"">Подготовил : </TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD width=""30%"">" v-ofc "</TD>" skip
    "</TR>" skip
    "<TR></TR>" skip
    "<TR valign=""top"">"
      "<TD>Дата : <U>" v-datastr "</U></TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
    "</TR>" skip
    "<TR>"
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>&nbsp;</TD>" skip
    "</TR></TABLE>" skip.

put stream v-out unformatted 
"</table>    " skip.
  
{html-end.i "stream v-out" }

output stream v-out close.
unix silent value("cptwin " + v-ofile + " iexplore").


