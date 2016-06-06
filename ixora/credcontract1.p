/* credcontract1.p
 * MODULE
        Экспресс кредиты по ПК
 * DESCRIPTION
        Описание
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
        08/11/2013 Luiza ТЗ 1932 создан по подобию credcontract.p добавила обработку if not available xml_det
 * BASES
        BANK COMM
 * CHANGES
            13/11/2013 Luiza ТЗ 2197 рефинансирование по нескольким кредитам

*/

{global.i}
def input parameter fcb_id as int no-undo.

def var xml_id as int no-undo.
find first fcb where fcb.fcb_id = fcb_id no-lock no-error.
if not avail fcb then return.
xml_id = fcb.xml_id.

def shared var v-cifcod   as char no-undo.
def shared var s-ln       as inte no-undo.
def shared var v-bank     as char no-undo.

def var v-start as int init 0.
def var v-end as int init 0.

def var v-count as int.
def var v-max as int init 100.
def var vstart as int extent 100.
def var vend as int extent 100.
def var i as int.
def var v-line as int.
def temp-table t-xml_det like xml_det.
def buffer b-xml for t-xml_det.
def stream r-out.

find first xml_det where xml_det.xml_id = xml_id  no-lock no-error.
if not avail xml_det then do:
    message "Отчет ПКБ не найден, повторите запрос в ПКБ!" view-as alert-box title 'ВНИМАНИЕ'.
    return.
end.

find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*CigResultError Errmessage" no-lock no-error.
if avail xml_det then do:
    message "1КБ: " + xml_det.val view-as alert-box title 'ВНИМАНИЕ'.
    if xml_det.val matches "*Субъект не найден*" or xml_det.val matches "*Не существует запрашиваемого отчета для данного субъекта*" then run emptyrep.
    return.
end.
find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Root ExistingContracts" no-lock no-error.
if not avail xml_det then do:
    message "Нет действующих контрактов!" view-as alert-box title 'ВНИМАНИЕ'.
    run emptyrep.
    return.
end.


procedure AddRecord :
  def input parameter param1 as char no-undo.
  def input parameter param2 as char no-undo.

  if param1 <> "" then do:
      find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches param1 + " title" no-lock no-error.
      if not available xml_det then put unformatted "<TR>" skip "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip.
      else put unformatted "<TR>" skip "<TD width=20>"  "</TD>" skip "<TD>" replace(xml_det.val,";","; ") "</TD>" skip.
      find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches param1 + " value" no-lock no-error.
      if not available xml_det then put unformatted "<TD>"  "</TD>" skip.
      else put unformatted "<TD>" replace(xml_det.val,";","; ") "</TD>" skip.
  end. else do:
      put unformatted "<TR>" skip "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip "<TD>" "</TD>" skip.
  end.
  if param2 <> "" then do:
      find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches param2 + " title" no-lock no-error.
      if not available xml_det then put unformatted "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip.
      else put unformatted "<TD width=20>"  "</TD>" skip "<TD>" replace(xml_det.val,";","; ") "</TD>" skip.
      find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches param2 + " value" no-lock no-error.
      if not available xml_det then put unformatted "<TD>" "</TD>" skip "</TR>" skip.
      else put unformatted "<TD>" replace(xml_det.val,";","; ") "</TD>" skip "</TR>" skip.
  end. else do:
      put unformatted "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip "<TD>"  "</TD>" skip "</TR>" skip.
  end.
end procedure.

procedure AddRecordColor :
  def input parameter param1 as char no-undo.
  def input parameter param2 as char no-undo.

  if param1 <> "" then do:
      find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches param1 + " title" no-lock no-error.
      if not available xml_det then put unformatted "<TR bgcolor=#D8D8D8>" skip "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip.
      else put unformatted "<TR bgcolor=#D8D8D8>" skip "<TD width=20>"  "</TD>" skip "<TD>" replace(xml_det.val,";","; ") "</TD>" skip.
      find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches param1 + " value" no-lock no-error.
      if not available xml_det then put unformatted "<TD>"  "</TD>" skip.
      else put unformatted "<TD>" replace(xml_det.val,";","; ") "</TD>" skip.
  end. else do:
      put unformatted "<TR bgcolor=#D8D8D8 >" skip "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip "<TD>" "</TD>" skip.
  end.
  if param2 <> "" then do:
      find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches param2 + " title" no-lock no-error.
      if not available xml_det then put unformatted "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip.
      else put unformatted "<TD width=20>"  "</TD>" skip "<TD>" replace(xml_det.val,";","; ") "</TD>" skip.
      find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches param2 + " value" no-lock no-error.
      if not available xml_det then put unformatted "<TD>"  "</TD>" skip "</TR>" skip.
      else put unformatted "<TD>" replace(xml_det.val,";","; ") "</TD>" skip "</TR>" skip.
  end. else do:
      put unformatted "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip "<TD>"  "</TD>" skip "</TR>" skip.
  end.
end procedure.


procedure AddRecord1 :
  def input parameter param1 as char no-undo.
  def input parameter param2 as char no-undo.

  if param1 <> "" then do:
      put unformatted "<TR>" skip "<TD width=20>"  "</TD>" skip "<TD>" param1 "</TD>" skip.
      put unformatted "<TD>"  "</TD>" skip.
  end. else do:
      put unformatted "<TR>" skip "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip "<TD>" "</TD>" skip.
  end.
  if param2 <> "" then do:
      put unformatted "<TD width=20>"  "</TD>" skip "<TD>" param2 "</TD>" skip.
      put unformatted "<TD>"  "</TD>" skip "</TR>" skip.
  end. else do:
      put unformatted "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip "<TD>"  "</TD>" skip "</TR>" skip.
  end.
end procedure.

procedure AddRecord1Color :
  def input parameter param1 as char no-undo.
  def input parameter param2 as char no-undo.

  if param1 <> "" then do:
      put unformatted "<TR bgcolor=#D8D8D8 >" skip "<TD width=20>"  "</TD>" skip "<TD>" param1 "</TD>" skip.
      put unformatted "<TD>"  "</TD>" skip.
  end. else do:
      put unformatted "<TR bgcolor=#D8D8D8 >" skip "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip "<TD>" "</TD>" skip.
  end.
  if param2 <> "" then do:
      put unformatted "<TD width=20>"  "</TD>" skip "<TD>" param2 "</TD>" skip.
      put unformatted "<TD>"  "</TD>" skip "</TR>" skip.
  end. else do:
      put unformatted "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip "<TD>"  "</TD>" skip "</TR>" skip.
  end.
end procedure.

procedure AddRecord2 :
  def input parameter param1 as char no-undo.
  def input parameter param2 as char no-undo.
  def input parameter st as int no-undo.
  def input parameter en as int no-undo.

  if param1 <> "" then do:
      find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= st and xml_det.line <= en and xml_det.par matches param1 + " title" no-lock no-error.
      if not available xml_det then  put unformatted "<TR>" skip "<TD width=20>"  "</TD>" skip "<TD>" "</TD>" skip.
      else put unformatted "<TR>" skip "<TD width=20>"  "</TD>" skip "<TD>" xml_det.val "</TD>" skip.
      find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= st and xml_det.line <= en and xml_det.par matches param1 + " value" no-lock no-error.
      if not available xml_det then put unformatted "<TD>"  "</TD>" skip.
      else put unformatted "<TD>" xml_det.val "</TD>" skip.
  end. else do:
      put unformatted "<TR>" skip "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip "<TD>" "</TD>" skip.
  end.
  if param2 <> "" then do:
      find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= st and xml_det.line <= en and xml_det.par matches param2 + " title" no-lock no-error.
      if not available xml_det then put unformatted "<TD width=20>"  "</TD>" skip "<TD>" "</TD>" skip.
      else put unformatted "<TD width=20>"  "</TD>" skip "<TD>" xml_det.val "</TD>" skip.
      find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= st and xml_det.line <= en and xml_det.par matches param2 + " value" no-lock no-error.
      if not available xml_det then put unformatted "<TD>"  "</TD>" skip "</TR>" skip.
      else put unformatted "<TD>" xml_det.val "</TD>" skip "</TR>" skip.
  end. else do:
      put unformatted "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip "<TD>"  "</TD>" skip "</TR>" skip.
  end.
end procedure.

procedure AddRecord2Color :
  def input parameter param1 as char no-undo.
  def input parameter param2 as char no-undo.
  def input parameter st as int no-undo.
  def input parameter en as int no-undo.

  if param1 <> "" then do:
      find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= st and xml_det.line <= en and xml_det.par matches param1 + " title" no-lock no-error.
      if not available xml_det then put unformatted "<TR bgcolor=#D8D8D8 >" skip "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip.
      else put unformatted "<TR bgcolor=#D8D8D8 >" skip "<TD width=20>"  "</TD>" skip "<TD>" xml_det.val "</TD>" skip.
      find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= st and xml_det.line <= en and xml_det.par matches param1 + " value" no-lock no-error.
      if not available xml_det then put unformatted "<TD>"  "</TD>" skip.
      else put unformatted "<TD>" xml_det.val "</TD>" skip.
  end. else do:
      put unformatted "<TR bgcolor=#D8D8D8 >" skip "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip "<TD>" "</TD>" skip.
  end.
  if param2 <> "" then do:
      find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= st and xml_det.line <= en and xml_det.par matches param2 + " title" no-lock no-error.
      if not available xml_det then put unformatted "<TD width=20 >"  "</TD>" skip "<TD>"  "</TD>" skip.
      else put unformatted "<TD width=20 >"  "</TD>" skip "<TD>" xml_det.val "</TD>" skip.
      find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= st and xml_det.line <= en and xml_det.par matches param2 + " value" no-lock no-error.
      if not available xml_det then put unformatted "<TD>"  "</TD>" skip "</TR>" skip.
      else put unformatted "<TD>" xml_det.val "</TD>" skip "</TR>" skip.
  end. else do:
      put unformatted "<TD width=20>"  "</TD>" skip "<TD>"  "</TD>" skip "<TD>"  "</TD>" skip "</TR>" skip.
  end.
end procedure.


def stream rep.
def var v-file  as char init "1cb_standardreport.html"  no-undo.

output to value(v-file).
{html-title.i &size-add = "x-"}

 put unformatted
   "<TABLE bordercolor=silver width=""600"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip.

put unformatted "<TR><TD colspan=6 height = 40 bgcolor=gray> Республика Казахстан. ТОО «Первое кредитное бюро» </TD></TR>" skip.

put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.

find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Root Header RegistrationID value" no-lock no-error.
put unformatted "<TR>" skip "<TD colspan=3 height = 40 bgcolor=gray> " "Кредитный отчет - стандарт" "</TD>" skip  "<TD width=20> "  "</TD>" skip "<TD>" "Регистрационный ИД" "</TD>" skip "<TD>" xml_det.val "</TD>" skip "</TR>" skip.
put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.

/*Уникальный номер финансового учреждения     Фамилия в настоящее время         */
run AddRecordColor("*Root Header FIUniqueNumberID","*Root Header Surname").
/*ИИН                                         Имя                               */
run AddRecordColor("*Root Header IIN","*Root Header Name").
/*РНН                                         Отчество                          */
run AddRecordColor("*Root Header RNN","*Root Header FathersName").
/*СИК                                         Фамилия по рождению               */
run AddRecordColor("*Root Header SIC","*Root Header BirthName").
/*Дата рождения                               Место рождения (город)            */
run AddRecordColor("*Root Header DateOfBirth","*Root Header CityOfBirth").
/*Пол                                         Место рождения ( область, район)  */
run AddRecordColor("*Root Header Gender","*Root Header RegionOfBirth").
/*Образование                                 Страна рождения (код страны)      */
run AddRecordColor("*Root Header Education","*Root Header CountryOfBirth").
/*Семейное положение*/
run AddRecordColor("*Root Header MatrialStatus","").


put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.

put unformatted "<TR><TD colspan=6 height = 20 bgcolor=silver>СУБЪЕКТ, СЕМЬЯ И ЗАНЯТОСТЬ </TD></TR>" skip.
/*Кол-во иждивенцев старше 18 лет         Улица            */
run AddRecordColor("*Root SubjectDetails NumberOfChildern","*Root SubjectDetails Street").
/*Кол-во иждивенцев до 18 лет             Город            */
run AddRecordColor("*Root SubjectDetails NumberOfDependents","*Root SubjectDetails City").
/*Зарплата (нетто)                        Почтовый индекс  */
run AddRecordColor("*Root SubjectDetails EmployeesSalary","*Root SubjectDetails ZipCode").
/*Домашний телефон                        Область, район   */
run AddRecordColor("*Root SubjectDetails HomePhone","*Root SubjectDetails Region").
/*Рабочий телефон                         Cтрана           */
run AddRecordColor("*Root SubjectDetails OfficePhone","*Root SubjectDetails Country").
/*Номер сотового телефона                 Номер факса      */
run AddRecordColor("*Root SubjectDetails CellularPhone","*Root SubjectDetails Fax").
/*E-Mail*/
run AddRecordColor("*Root SubjectDetails Email","").

put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.



put unformatted "<TR><TD colspan=6 height = 20 bgcolor=silver> АДРЕС ПОСТОЯННОГО МЕСТА ПРОЖИВАНИЯ – ТЕКУЩИЙ И БЫВШИЙ</TD></TR>" skip.
do i = 1 to v-max:
   vstart[i] = 0.
   vend[i] = 0.
end.
v-count = 0.
for each xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Root SubjectsAddress Address title" no-lock.
   v-count = v-count + 1.
   if v-count > 1 then vend[v-count - 1] = xml_det.line.
   vstart[v-count] = xml_det.line.
end.
find last xml_det where xml_det.xml_id = xml_id  no-lock no-error.
vend[v-count] = xml_det.line.
do i = 1 to v-count:
    find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[i] and xml_det.line <= vend[i]
             and xml_det.par matches "*Root SubjectsAddress Address title" no-lock no-error.
    if not available xml_det then put unformatted "<TR><TD colspan=6 bgcolor=#D8D8D8> "  " </TD></TR>" skip.
    else put unformatted "<TR><TD colspan=6 bgcolor=#D8D8D8> " + xml_det.val + " </TD></TR>" skip.
    run AddRecord2("*Root SubjectsAddress Address Street","*Root SubjectsAddress Address ZipCode",vstart[i],vend[i]).
    run AddRecord2("*Root SubjectsAddress Address City","*Root SubjectsAddress Address Region",vstart[i],vend[i]).
    run AddRecord2("*Root SubjectsAddress Address HomePhone","*Root SubjectsAddress Address OfficePhone",vstart[i],vend[i]).
    run AddRecord2("*Root SubjectsAddress Address CellularPhone","*Root SubjectsAddress Address Fax",vstart[i],vend[i]).
    run AddRecord2("*Root SubjectsAddress Address EmailAddress","*Root SubjectsAddress Address AddressInserted",vstart[i],vend[i]).
    run AddRecord2("*Root SubjectsAddress Address WebPageAddress","",vstart[i],vend[i]).
end.

put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.
put unformatted "<TR><TD colspan=6 height = 20 bgcolor=silver>АДРЕС МЕСТА ПРОПИСКИ - ТЕКУЩИЙ И БЫВШИЙ</TD></TR>" skip.
put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.
put unformatted "<TR><TD colspan=6 height = 20 bgcolor=silver>ДОКУМЕНТЫ УДОСТОВЕРЯЮЩИЕ ЛИЧНОСТЬ – НАСТОЯЩАЯ И ИСТОРИЧЕСКАЯ ИНФОРМАЦИЯ</TD></TR>" skip.
do i = 1 to v-max:
   vstart[i] = 0.
   vend[i] = 0.
end.
v-count = 0.
for each xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*IdentificationDocuments Document" no-lock.
   v-count = v-count + 1.
   if v-count > 1 then vend[v-count - 1] = xml_det.line - 1.
   vstart[v-count] = xml_det.line.
end.
find last xml_det where xml_det.xml_id = xml_id  no-lock no-error.
vend[v-count] = xml_det.line.
do i = 1 to v-count:
    find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[i] and xml_det.line <= vend[i]
           and xml_det.par matches "*IdentificationDocuments Document rank" no-lock no-error.
    if not available xml_det then put unformatted "<TR><TD colspan=6 bgcolor=#D8D8D8> " " </TD></TR>" skip.
    else put unformatted "<TR><TD colspan=6 bgcolor=#D8D8D8> " + xml_det.val + " </TD></TR>" skip.
    run AddRecord2("*IdentificationDocuments Document Name","*IdentificationDocuments Document DateOfRegistration",vstart[i],vend[i]).
    run AddRecord2("*IdentificationDocuments Document DateOfIssuance","*IdentificationDocuments Document Number",vstart[i],vend[i]).
    run AddRecord2("*IdentificationDocuments Document IssuanceLocation","*IdentificationDocuments Document DateOfExpiration",vstart[i],vend[i]).
    put unformatted "<TR><TD colspan=6 height = 10> </TD></TR>" skip.
end.


put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.
put unformatted "<TR><TD colspan=6 height = 20 bgcolor=silver> СОЦИАЛЬНО-ЭКОНОМИЧЕСКИЙ СТАТУС</TD></TR>" skip.
run AddRecord("*ClassificationOfBorrower BorrowerClassification","*ClassificationOfBorrower Patent").
run AddRecord("*ClassificationOfBorrower Resident","*ClassificationOfBorrower SubjectsPosition").
run AddRecord("*ClassificationOfBorrower Citizenship","*ClassificationOfBorrower SubjectsEmployment").
run AddRecord("*ClassificationOfBorrower ForeignersCitizenship","*ClassificationOfBorrower EconomicActivityGroup").

put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.
put unformatted "<TR><TD colspan=6 height = 20 bgcolor=silver> СТАТУС СУБЪЕКТА</TD></TR>" skip.

find last xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*NegativeData NegativeStatus typeTitle" and xml_det.val = "Исторический" no-lock no-error.
if avail xml_det then v-line = xml_det.line. else do:
   find last xml_det where xml_det.xml_id = xml_id no-lock no-error.
   v-line = xml_det.line.
end.

do i = 1 to v-max: vstart[i] = 0. vend[i] = 0. end.
v-count = 0.
for each xml_det where xml_det.xml_id = xml_id and xml_det.line < v-line and xml_det.par matches "*NegativeData NegativeStatus NegativeStatusOfContract NegativeStatusOfContract" no-lock.
   v-count = v-count + 1.
   if v-count > 1 then vend[v-count - 1] = xml_det.line - 1.
   vstart[v-count] = xml_det.line.
end.
vend[v-count] = v-line.
do i = 1 to v-count:
    find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[i] and xml_det.line <= vend[i]
           and xml_det.par matches "*NegativeData NegativeStatus NegativeStatusOfContract RegistrationDate value" no-lock no-error.
   if not available xml_det then put unformatted "<TR bgcolor=#D8D8D8><TD colspan=3> Текущие </TD><TD colspan=2> Последняя дата записи в систему </TD><TD> "  " </TD></TR>" skip.
   else put unformatted "<TR bgcolor=#D8D8D8><TD colspan=3> Текущие </TD><TD colspan=2> Последняя дата записи в систему </TD><TD> " + xml_det.val + " </TD></TR>" skip.
   run AddRecord2("*NegativeData NegativeStatus NegativeStatusOfContract NegativeStatusOfContract","",vstart[i],vend[i]).
end.

do i = 1 to v-max: vstart[i] = 0. vend[i] = 0. end.
v-count = 0.
for each xml_det where xml_det.xml_id = xml_id and xml_det.line >= v-line and xml_det.par matches "*NegativeData NegativeStatus NegativeStatusOfContract NegativeStatusOfContract" no-lock.
   v-count = v-count + 1.
   if v-count > 1 then vend[v-count - 1] = xml_det.line - 1.
   vstart[v-count] = xml_det.line.
end.
if v-count <> 0 then do:
    find last xml_det where xml_det.xml_id = xml_id no-lock no-error.
    vend[v-count] = xml_det.line.
    do i = 1 to v-count:
        find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[i] and xml_det.line <= vend[i]
               and xml_det.par matches "*NegativeData NegativeStatus NegativeStatusOfContract RegistrationDate value" no-lock no-error.
       if not available xml_det then put unformatted "<TR bgcolor=#D8D8D8><TD colspan=3> Исторический </TD><TD colspan=2> Последняя дата записи в систему </TD><TD> "  " </TD></TR>" skip.
       else put unformatted "<TR bgcolor=#D8D8D8><TD colspan=3> Исторический </TD><TD colspan=2> Последняя дата записи в систему </TD><TD> " + xml_det.val + " </TD></TR>" skip.
       run AddRecord2("*NegativeData NegativeStatus NegativeStatusOfContract NegativeStatusOfContract","",vstart[i],vend[i]).
    end.
end.



put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.
put unformatted "<TR><TD colspan=6 height = 20 bgcolor=silver> Общая информация - заемщик</TD></TR>" skip.
run AddRecordColor("*SummaryInformationDebtor NumberOfExistingContracts NumberOfExistingContracts","*SummaryInformationDebtor TotalOutstandingDebt TotalOutstandingDebt").
run AddRecord("*SummaryInformationDebtor NumberOfExistingContracts InstalmentCredits","*SummaryInformationDebtor TotalOutstandingDebt InstalmentCredits").
run AddRecord("*SummaryInformationDebtor NumberOfExistingContracts CreditCardsRevolvingCredits","*SummaryInformationDebtor TotalOutstandingDebt CreditCardsRevolvingCredits").
run AddRecord("*SummaryInformationDebtor NumberOfExistingContracts NonInstalmentCredits","*SummaryInformationDebtor TotalOutstandingDebt NonInstalmentCredits").
run AddRecordColor("*SummaryInformationDebtor NumberOfTerminatedContracts NumberOfTerminatedContracts","*SummaryInformationDebtor TotalDebtOverdue TotalDebtOverdue").
run AddRecord("*SummaryInformationDebtor NumberOfTerminatedContracts InstalmentCredits","*SummaryInformationDebtor TotalDebtOverdue InstalmentCredits").
run AddRecord("*SummaryInformationDebtor NumberOfTerminatedContracts CreditCardsRevolvingCredits","*SummaryInformationDebtor TotalDebtOverdue CreditCardsRevolvingCredits").
run AddRecord("*SummaryInformationDebtor NumberOfTerminatedContracts NonInstalmentCredits","*SummaryInformationDebtor TotalDebtOverdue NonInstalmentCredits").
run AddRecordColor("*SummaryInformationDebtor NumberOfRejectedApplications NumberOfRejectedApplications","*SummaryInformationDebtor NumberOfInquiries").
run AddRecord("*SummaryInformationDebtor NumberOfRejectedApplications InstalmentCredits","*SummaryInformationDebtor NumberOfInquiries FirstQuarter").
run AddRecord("*SummaryInformationDebtor NumberOfRejectedApplications CreditCardsRevolvingCredits","*SummaryInformationDebtor NumberOfInquiries SecondQuarter").
run AddRecord("*SummaryInformationDebtor NumberOfRejectedApplications NonInstalmentCredits","*SummaryInformationDebtor NumberOfInquiries ThirdQuarter").
run AddRecord("","*SummaryInformationDebtor NumberOfInquiries FourthQuarter").

put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.
put unformatted "<TR><TD colspan=6 height = 20 bgcolor=silver> Общая информация - гарант</TD></TR>" skip.
run AddRecordColor("*SummaryInformationGuarantor NumberOfExistingContracts NumberOfExistingContracts","*SummaryInformationGuarantor TotalOutstandingDebt TotalOutstandingDebt").
run AddRecord("*SummaryInformationGuarantor NumberOfExistingContracts InstalmentCredits","*SummaryInformationGuarantor TotalOutstandingDebt InstalmentCredits").
run AddRecord("*SummaryInformationGuarantor NumberOfExistingContracts CreditCardsRevolvingCredits","*SummaryInformationGuarantor TotalOutstandingDebt CreditCardsRevolvingCredits").
run AddRecord("*SummaryInformationGuarantor NumberOfExistingContracts NonInstalmentCredits","*SummaryInformationGuarantor TotalOutstandingDebt NonInstalmentCredits").
run AddRecordColor("*SummaryInformationGuarantor NumberOfTerminatedContracts NumberOfTerminatedContracts","*SummaryInformationGuarantor TotalDebtOverdue TotalDebtOverdue").
run AddRecord("*SummaryInformationGuarantor NumberOfTerminatedContracts InstalmentCredits","*SummaryInformationGuarantor TotalDebtOverdue InstalmentCredits").
run AddRecord("*SummaryInformationGuarantor NumberOfTerminatedContracts CreditCardsRevolvingCredits","*SummaryInformationGuarantor TotalDebtOverdue CreditCardsRevolvingCredits").
run AddRecord("*SummaryInformationGuarantor NumberOfTerminatedContracts NonInstalmentCredits","*SummaryInformationGuarantor TotalDebtOverdue NonInstalmentCredits").
run AddRecordColor("*SummaryInformationGuarantor NumberOfRejectedApplications NumberOfRejectedApplications","*SummaryInformationGuarantor NumberOfInquiries").
run AddRecord("*SummaryInformationGuarantor NumberOfRejectedApplications InstalmentCredits","*SummaryInformationGuarantor NumberOfInquiries FirstQuarter").
run AddRecord("*SummaryInformationGuarantor NumberOfRejectedApplications CreditCardsRevolvingCredits","*SummaryInformationGuarantor NumberOfInquiries SecondQuarter").
run AddRecord("*SummaryInformationGuarantor NumberOfRejectedApplications NonInstalmentCredits","*SummaryInformationGuarantor NumberOfInquiries ThirdQuarter").
run AddRecord("","*SummaryInformationGuarantor NumberOfInquiries FourthQuarter").

put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.


put unformatted "<TR><TD colspan=6 height = 20 bgcolor=silver> ПОДРОБНАЯ ИНФОРМАЦИЯ – ДЕЙСТВУЮЩИЕ ДОГОВОРА</TD></TR>" skip.

do i = 1 to v-max:
   vstart[i] = 0.
   vend[i] = 0.
end.

v-count = 0.
for each xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Contract ContractTypeCode*" no-lock.
   v-count = v-count + 1.
   if v-count > 1 then vend[v-count - 1] = xml_det.line - 1.
   vstart[v-count] = xml_det.line.
end.

find last xml_det where xml_det.xml_id = xml_id  no-lock no-error.
vend[v-count] = xml_det.line.

do i = 1 to v-count:
    /*Код контракта                                           Номер договора                               */
    run AddRecord2Color("*Contract CodeOfContract","*Contract AgreementNumber",vstart[i],vend[i]).
    /*Цель кредита                                            Вид финансирования                           */
    run AddRecord2("*Contract PurposeOfCredit","*Contract TypeOfFounding",vstart[i],vend[i]).
    /*Статус договора                                         Код валюты                                   */
    run AddRecord2("*Contract ContractStatus","*Contract CurrencyCode",vstart[i],vend[i]).
    /*Дата начала срока действия договора                     Дата окончания срока действия договора       */
    run AddRecord2("*Contract DateOfCreditStart","*Contract DateOfCreditEnd",vstart[i],vend[i]).
    /*Дата заявки                                             Классификация договора                       */
    run AddRecord2("*Contract DateOfApplication","*Contract ClassificationOfContract",vstart[i],vend[i]).
    /*Стоимость обеспечения                                   Вид обеспечения                              */
    run AddRecord2("*Contract Collateral ValueOfGuarantee","*Contract Collateral TypeOfGuarantee",vstart[i],vend[i]).
    /*Признак связанности с банком особыми отношениями        Размер провизии                              */
    run AddRecord2("*Contract SpecialRelationship","*Contract AmountProvisions",vstart[i],vend[i]).
    /*Годовая эффективная ставка вознаграждения               Ссудный счет                                 */
    run AddRecord2("*Contract AnnualEffectiveRate","*Contract LoanAccount",vstart[i],vend[i]).
    /*Номинальная ставка вознаграждения                       Льготный период по основному долгу           */
    run AddRecord2("*Contract NominalRate","*Contract GracePrincipal",vstart[i],vend[i]).
    /*Общая сумма кредита/валюта                              Льготный период по вознаграждению            */
    run AddRecord2("*Contract TotalAmount","*Contract GracePay",vstart[i],vend[i]).
    /*Периодичность платежей                                  Фактическая дата погашения                   */
    run AddRecord2("*Contract PeriodicityOfPayments","*Contract DateOfRealRepayment",vstart[i],vend[i]).
    /*Общее количество платежей                               Кол-во непогашенных (предстоящих) платежей   */
    run AddRecord2("*Contract NumberOfInstalments","*Contract NumberOfOutstandingInstalments",vstart[i],vend[i]).
    /*Количество дней просрочки                               Непогашенная сумма по кредиту                */
    run AddRecord2("*Contract NumberOfOverdueInstalments","*Contract OutstandingAmount",vstart[i],vend[i]).
    /*Форма расчёта                                           Сумма предстоящего платежа                   */
    run AddRecord2("*Contract MethodOfPayments","*Contract MonthlyInstalmentAmount",vstart[i],vend[i]).
    /*Сумма просроченных взносов                              Штраф                                        */
    run AddRecord2("*Contract OverdueAmount","*Contract Penalty",vstart[i],vend[i]).
    /*Пеня                                                    Кол-во пролонгаций                           */
    run AddRecord2("*Contract Fine","*Contract ProlongationCount",vstart[i],vend[i]).
    /*Дата последнего обновления                              Роль субъекта                                */
    run AddRecord2("*Contract LastUpdate","*Contract SubjectRole",vstart[i],vend[i]).
    /*Источник информации (Кредитор)                          Место освоения кредита                       */
    run AddRecord2("*Contract FinancialInstitution","*Contract PlaceOfDisbursement",vstart[i],vend[i]).
    /*Местонахождение филиала*/
    run AddRecord2("*Contract BranchLocation","",vstart[i],vend[i]).

   empty temp-table t-xml_det.
   for each xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[i] and xml_det.line <= vend[i] no-lock.
       create t-xml_det.
       buffer-copy xml_det to t-xml_det.
   end.

   put unformatted "<TR><TD colspan=6>"  skip.
   put unformatted
   "<TABLE bordercolor=silver width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip.
   put unformatted "<TR>" skip.
   for each t-xml_det where t-xml_det.par matches "*ExistingContracts Contract PaymentsCalendar Payment".
      find first b-xml where b-xml.line = t-xml_det.line + 1 no-lock no-error.
      put unformatted "<TD>" + b-xml.val +  "</TD>" skip.
   end.
   put unformatted "</TR>" skip.

   put unformatted "<TR>" skip.
   for each t-xml_det where t-xml_det.par matches "*ExistingContracts Contract PaymentsCalendar Payment".
      find first b-xml where b-xml.line = t-xml_det.line + 2 no-lock no-error.
      put unformatted "<TD>" + b-xml.val +  "</TD>" skip.
   end.
   put unformatted "</TR>" skip.
   put unformatted "</TABLE>" skip.
   put unformatted "</TD></TR>" skip.

   run AddRecord("","").
end.

put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.
put unformatted "<TR><TD colspan=6 height = 20 bgcolor=silver> СВЯЗАННЫЕ ОБЬЕКТЫ (2-Я ФАЗА)</TD></TR>" skip.
do i = 1 to v-max:  vstart[i] = 0.  vend[i] = 0. end.
v-count = 0.
for each xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*InterconnectedSubjects InterconnectedSubject" no-lock.
   v-count = v-count + 1.
   if v-count > 1 then vend[v-count - 1] = xml_det.line - 1.
   vstart[v-count] = xml_det.line.
end.
find last xml_det where xml_det.xml_id = xml_id  no-lock no-error.
vend[v-count] = xml_det.line.
do i = 1 to v-count:
    find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[i] and xml_det.line <= vend[i]
           and xml_det.par matches "*InterconnectedSubjects InterconnectedSubject TypeOfLink value" no-lock no-error.
    if not available xml_det then put unformatted
         "<TR>" skip
         "<TD width=20>"  "</TD>" skip
         "<TD>Роль субъекта</TD>" skip
         "<TD>"    "</TD>" skip.

    else put unformatted
       "<TR>" skip
         "<TD width=20>"  "</TD>" skip
         "<TD>Роль субъекта</TD>" skip
         "<TD>" + xml_det.val +   "</TD>" skip.

    find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[i] and xml_det.line <= vend[i]
           and xml_det.par matches "*InterconnectedSubjects InterconnectedSubject SubjectCode value" no-lock no-error.
    if not available xml_det then put unformatted
         "<TD width=20>"  "</TD>" skip
         "<TD>Регистрационный ИД</TD>" skip
         "<TD>"   "</TD>" skip
       "</TR>" skip.
    else put unformatted
         "<TD width=20>"  "</TD>" skip
         "<TD>Регистрационный ИД</TD>" skip
         "<TD>" + xml_det.val +  "</TD>" skip
       "</TR>" skip.
end.


put unformatted "<TR><TD colspan=6 height = 15> </TD></TR>" skip.
find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Footer DateOfIssue value" no-lock no-error.
if not available xml_det then put unformatted "<TR bgcolor=gray><TD colspan=4 height = 20 > КОНЕЦ КРЕДИТНОГО ОТЧЕТА</TD><TD>Дата формирования кредитного отчета</TD><TD>"  "</TD></TR>" skip.
else put unformatted "<TR bgcolor=gray><TD colspan=4 height = 20 > КОНЕЦ КРЕДИТНОГО ОТЧЕТА</TD><TD>Дата формирования кредитного отчета</TD><TD>" + xml_det.val + "</TD></TR>" skip.

find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Footer ContactInfo value" no-lock no-error.
if not available xml_det then put unformatted "<TR><TD colspan=6 bgcolor=gray> "  " </TD></TR>" skip.
else put unformatted "<TR><TD colspan=6 bgcolor=gray> " + xml_det.val + " </TD></TR>" skip.




put unformatted "</TABLE>" skip.

{html-end.i " "}
output close.


unix silent cptwin value(v-file) iexplore.

procedure emptyrep:
    find first pkanketa where pkanketa.bank = v-bank and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln and pkanketa.credtype = "10" use-index bankcif no-lock no-error.
    find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.cif = v-cifcod no-lock no-error.
    output stream r-out to fin.htm.
    put stream r-out unformatted "<html><head><title></title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
    put stream r-out unformatted "<br><br>  АО 'ForteBank' <br>" skip.
    put stream r-out unformatted "<br>" "Отчет ПКБ для экспресс кредита по клиенту " + v-cifcod  + " № анкеты " + string(s-ln) " от " string(pkanketa.rdt) "<br>" skip.
    put stream r-out unformatted "<br><br>" skip.

        put stream r-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
        "<tr style=""font:bold"">"
        "<td align=""center"" valign=""top""> ФИО клиента</td>"
        "<td align=""center"" valign=""top""> ИИН </td>"
        "<td align=""center"" valign=""top""> Дата рождения </td>"
        "<td align=""center"" valign=""top""> Статус </td>"
        "</tr>"
        "<tr style=""font:bold"">"
        "<td align=""center"" valign=""top"">" pkanketa.name "</td>"
        "<td align=""center"" valign=""top""> " pkanketa.rnn " </td>"
        "<td align=""center"" valign=""top""> " string(pcstaff0.birth) " </td>"
        "<td align=""center"" valign=""top""> По клиенту в базе Кредитного Бюро отсутствуют действующие кредиты </td>"
        "</tr>" skip.
    put stream r-out unformatted "</table>" skip.
    put stream r-out unformatted "<br><br>" skip.

    output stream r-out close.
    unix silent cptwin fin.htm iexplore.
end procedure.

