/* pkaist.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Отчет по сверке телефонных номеров с базой АИСТ
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
        26/05/2006 madiyar
 * BASES
        bank, comm
 * CHANGES
        25/04/2007 madiyar - добавились параметры в вызове pkaistrep
*/

{global.i}
{pk.i}

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def var pars as char no-undo extent 6.

find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = 'tel' no-lock no-error.
if avail pkanketh then assign pars[1] = trim(pkanketh.value1) pars[2] = trim(pkanketh.rescha[1]).
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = 'tel2' no-lock no-error.
if avail pkanketh then assign pars[3] = trim(pkanketh.value1) pars[4] = trim(pkanketh.rescha[1]).
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = 'tel4' no-lock no-error.
if avail pkanketh then assign pars[5] = trim(pkanketh.value1) pars[6] = trim(pkanketh.rescha[1]).

run pkaistrep(pars[1],pars[2],pars[3],pars[4],pars[5],pars[6],s-credtype,s-pkankln).

