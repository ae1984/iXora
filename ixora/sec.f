/* sec.f
 * MODULE
        Название модуля
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        11.11.2011 damir - перекомпиляция
*/

def var v-rnnokpo    as char.
def var v-namecomp1  as char.
def var v-namecomp2  as char.
def var v-namecomp3  as char.
def var v-dtnumreg1  as char.
def var v-dtnumreg2  as char.
def var v-whoreg1    as char.
def var v-whoreg2    as char.
def var v-whoreg3    as char.
def var v-address1   as char.
def var v-address2   as char.
def var v-address3   as char.
def var v-fiomain1   as char.
def var v-fiomain2   as char.
def var v-fiomain3   as char.
def var v-tel        as char.
def var v-busstype1  as char.
def var v-busstype2  as char.
def var v-busstype3  as char.
def var v-wherefil1  as char.
def var v-wherefil2  as char.
def var v-dtbegend1  as char.
def var v-dtbegend2  as char.
def var v-dtbegend3  as char.
def var v-summreq1   as char.
def var v-summreq2   as char.
def var v-summreq3   as char.
def var v-criter1    as char.
def var v-criter2    as char.
def var v-criter3    as char.
def var v-criter4    as char.
def var v-criter5    as char.
def var v-criter6    as char.
def var v-moreinfo1  as char.
def var v-moreinfo2  as char.
def var v-moreinfo3  as char.
def var v-moreinfo4  as char.
def var v-moreinfo5  as char.
def var v-moreinfo6  as char.
def var v-moreinfo7  as char.
def var v-moreinfo8  as char.
def var v-moreinfo9  as char.
def var v-moreinfo10 as char.
def var v-result1    as char.
def var v-result2    as char.
def var v-result3    as char.

form
    v-rnnokpo   label "РНН предприятия" format "x(16)" colon 41 skip
    v-namecomp1 label "Наименование предприятия" format "x(64)" colon 41 skip
    v-namecomp2 no-label format "x(106)" skip
    v-namecomp3 no-label format "x(106)" skip
    v-dtnumreg1 label "Дата и № регистрации" format "x(64)" colon 41 skip
    v-dtnumreg2 no-label format "x(106)" skip
    v-whoreg1   label "Кем зарегистрирован (Администр.субъект)" format "x(64)" colon 41 skip
    v-whoreg2   no-label format "x(106)" skip
    v-whoreg3   no-label format "x(106)" skip
    v-address1  label "Адрес факт.месторасположения предприятия" format "x(64)" colon 41 skip
    v-address2  no-label format "x(106)" skip
    v-address3  no-label format "x(106)" skip
    v-fiomain1  label "ФИО руководителя" format "x(64)" colon 41 skip
    v-fiomain2  no-label format "x(106)" skip
    v-fiomain3  no-label format "x(106)" skip
    v-tel       label "Контактные телефоны" format "x(64)" colon 41 skip
    v-busstype1 label "Основной вид деятельности" format "x(64)" colon 41 skip
    v-busstype2 no-label format "x(106)" skip
    v-busstype3 no-label format "x(106)" skip
    v-wherefil1 label "Место обращения заемщика" format "x(64)" colon 41 skip
    v-wherefil2 no-label format "x(106)" skip
    v-dtbegend1 label "Дата нач. и окон. рассм.кредитн проекта" format "x(64)" colon 41 skip
    v-dtbegend2 no-label format "x(106)" skip
    v-dtbegend3 no-label format "x(106)" skip
    v-summreq1  label "Сумма запрашиваемого кредита" format "x(64)" colon 41 skip
    v-summreq2  no-label format "x(106)" skip
    v-summreq3  no-label format "x(106)" skip
    v-criter1   label "Критерии экспертизы по оценке безопаст." format "x(64)" colon 41 skip
    v-criter2   no-label  format "x(106)" skip
    v-criter3   no-label  format "x(106)" skip
    v-criter4   no-label  format "x(106)" skip
    v-criter5   no-label  format "x(106)" skip
    v-criter6   no-label  format "x(106)" skip
    v-moreinfo1 label "Доп.сведения связанных лиц и компаний" format "x(64)" colon 41 skip
    v-moreinfo2 no-label format "x(106)" skip
    v-moreinfo3 no-label format "x(106)" skip
    v-moreinfo4 no-label format "x(106)" skip
    v-moreinfo5 no-label format "x(106)" skip
    v-moreinfo6 no-label format "x(106)" skip
    v-moreinfo7 no-label format "x(106)" skip
    v-moreinfo8 no-label format "x(106)" skip
    v-moreinfo9 no-label format "x(106)" skip
    v-moreinfo10 no-label format "x(79)" skip
    v-result1   label "Результат принятого решения" format "x(64)" colon 41 skip
    v-result2   no-label format "x(106)" skip
    v-result3   no-label format "x(106)" skip
with centered row 3 width 110 side-labels frame sec.





