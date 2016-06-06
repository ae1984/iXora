/* vccthis0.p
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        12/03/2008 galina - перекомпиляция в связи с изменением vccontrs.f
        13.05.2008 galina - добавлен вывод полей "СУММА ЗАЙМ.%" и "СРОК ДВИЖ.КАП."
        06.06.2008 galina - добавления поля остаток непереведенных средств
        25.07.2008 galina - перекомпиляция в связи с изменением vccontrs.f
        09.01.2009 galina - перекомпиляция в связи с изменением vccontrs.f
        14.08.2009 galina - перекомпиляция в связи с изменением vccontrs.f
        26.08.2009 galina - в процедуру check_term не передаем дату
        30.12.2009 galina - перекомпиляция в связи с изменением vccontrs.f
        27.04.2011 aigul - в связи с изменениями vccontrs.f добавила временные переменные ИНН, счета получателя, банк бенефициара, банк-корреспондент
        08.08.2011 damir - объявил переменные v-valogov1,v-valogov2
        09.09.2011 damir - объявил переменную v-check.
 */

/* vccthis.p Валютный контроль
   История контракта

   08.11.2002 nadejda создан

*/

{vc.i}
def var v-bb as char.
def var v-bb1 as char.
def var v-bb2 as char.
def var v-bb3 as char.

def var v-bc as char.
def var v-bc1 as char.
def var v-bc2 as char.
def var v-bc3 as char .

def var v-valogov1 as char.
def var v-valogov2 as char.
def var v-check as logi init no.

{vc-vhis.i
 &head = "vccontrs"
 &headkey = "contract"
 &headhis = "vccthis"
 &frame = "vccontrs"
 &predisplay = "
      find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
      if avail vcpartners then
        v-partnername = trim(trim(vcpartners.name) + ' ' + trim(vcpartners.formasob)).
      else v-partnername = ''.
      find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
      v-crcname = ncrc.code.
      run vcctsumm.
      if vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1' then
       run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
      v-vcaaa = vccontrs.aaa. "
 &header = "КОНТРАКТА "
 &displcif = "false"
 &display = "
      vccontrs.ctnum vccontrs.sts vccontrs.expimp vccontrs.ctdate vccontrs.cttype
      vccontrs.partner v-partnername
      vccontrs.ncrc v-crcname vccontrs.ctsum vccontrs.info[1] v-vcaaa
      vccontrs.lastdate vccontrs.cursdoc-usd vccontrs.ctsum / vccontrs.cursdoc-usd @ v-ctsumusd
      vccontrs.info[2] vccontrs.info[3] vccontrs.rdt vccontrs.rwho vccontrs.cdt vccontrs.cwho
      vccontrs.ctvalpl vccontrs.ctformrs vccontrs.ctterm vccontrs.cardnum
      v-sumost1 v-suminv v-sumkon v-sumexc v-sumgtd v-sumplat v-sumakt v-sumost v-sumexc% v-term"
}



