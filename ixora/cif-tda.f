/* cif-tda.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        22/08/03 nataly изменен формат aaa.pri , pri.pri c "x(1)"  - > "x(3)"
        20.05.2004 nadejda - добавлена информация, является ли счет исключением по % ставке
        21.06.2004 nadejda - добавлена проверка исключительной ставки на отличие от ставки по умолчанию
        01.07.2004 dpuchkov - добавил проверку на привязку к курсу USD для VIP депозитов
        03.09.04 dpuchkov - добавил привязку валютных VIP депозитов к тенге в соответствии с изменением в законодательстве(ТЗ1100)
        18.10.04 sasco - убрал проверку % ставки на > 0.  Теперь можно >= 0.
        31.10.2006 u00124 добавил Максимальную сумму депозита.
*/

def var v-excl as logical init no.

def var d-effect as decimal init 0.

/*
function chkgacc returns logical (p-val2 as DECIMAL).
 find last crc where crc.crc = 2 no-lock no-error.
 if lgr.usdval = True then do:
   if p-val2 >= crc.rate[1] * lgr.tlimit[1] then return true.
   else return False.
 end.
 else
 do:
    if p-val2 >= lgr.tlimit[1]  then return true.
    else
      return false.
 end.
end.


function chksum returns decimal ().
 find last crc where crc.crc = 2 no-lock no-error.
 if lgr.usdval = True  then do:
    return crc.rate[1] * lgr.tlimit[1].
 end.
 else
 do:
    return lgr.tlimit[1].
 end.
end.
*/

function chkgacc returns logical (p-val2 as DECIMAL).

 find last crc where crc.crc = lgr.crc no-lock no-error.

 if lgr.usdval = True then do:
   if (p-val2 >= lgr.tlimit[1] / crc.rate[1]) and (((p-val2 <= lgr.tlimit[4] / crc.rate[1]) and lgr.tlimit[4] <> 0) or lgr.tlimit[4] = 0)  then return true.
   else return False.
 end.
 else
 do:
    if (p-val2 >= lgr.tlimit[1]) and ((p-val2 <= lgr.tlimit[4] and lgr.tlimit[4] <> 0) or lgr.tlimit[4] = 0)   then return true.
    else
      return false.
 end.
end.


function chksum returns decimal ().
 find last crc where crc.crc = lgr.crc no-lock no-error.
 if lgr.usdval = True  then do:
    return lgr.tlimit[1] / crc.rate[1].
 end.
 else
 do:
    return lgr.tlimit[1].
 end.
end.

function chksumMin returns decimal ().
 find last crc where crc.crc = lgr.crc no-lock no-error.
 if lgr.usdval = True  then do:
    return lgr.tlimit[4] / crc.rate[1].
 end.
 else
 do:
    return lgr.tlimit[4].
 end.
end.





form  aaa.aaa    label "Номер счета             " skip
      aaa.cla format ">9" label "Срок вклада (месяцев)    "
              validate(aaa.cla >= lgr.prd and (aaa.cla <= lgr.dueday or lgr.dueday = 0),
                       "Срок вклада должен быть >=" + string(lgr.prd,">9") +
                       " и <= " + string(lgr.dueday,">9")) 
              help "Введите срок вклада в целых месяцах"
      termdays format ">>>9" label "      дней " skip
      aaa.lstmdt label "Дата начала             "
                 validate(aaa.lstmdt >= g-today, "Должно быть >= даты операционного дня")
                 help "Введите дате начала депозита" skip
      aaa.expdt  label "Дата окончания          " skip


      aaa.opnamt label "Начальная сумма вклада  " format ">>>,>>>,>>>,>>9.99"
                  validate(chkgacc(aaa.opnamt) , "Сумма должна быть >= " 
                  + trim(string(chksum() , ">>>,>>>,>>>,>>>.99") ) + " и <= " + trim(string(chksumMin() , ">>>,>>>,>>>,>>>.99") )) skip


/*      aaa.opnamt label "Начальная сумма вклада  " format ">>>,>>>,>>>,>>9.99"
                 validate(aaa.opnamt >= lgr.tlimit[1], "Сумма вклада должна быть >= " 
                          + trim(string(lgr.tlimit[1],">>>,>>>,>>>,>>>.99"))) skip
*/

      mbal label       "Конечная сумма вклада   " format ">>>,>>>,>>>,>>9.99" skip
      aaa.pri format "x(3)"    label "Код таблицы % ставок    "  validate(can-find(first pri where pri.pri begins "^" + aaa.pri), "Таблица % ставок с таким кодом не существует")              help "Введите код таблицы % ставок"     skip
      v-excl     label "Исключение по % ставке? " format "да/нет" skip
      aaa.rate   label "% ставка                " format ">>>9.99"       help " Введите исключительную % ставку"  validate (aaa.rate >= 0 and aaa.rate <> v-rate, " Исключительная ставка должна отличаться от ставки по группе!")     skip
      d-effect   label "Эффективная ставка      " format ">>>9.99"

      skip
      with row 5 centered  side-label overlay title " Параметры депозитного вклада " frame aaa.
 
