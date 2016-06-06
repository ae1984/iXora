/* pkdogacc.p
 * MODULE
        ПотребКредит
 * DESCRIPTION
        Печать договора на открытие счета - для всех видов кредитов
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
        14.03.2003 nadejda
        13/05/2005 madiyar - соц.рейтинг, изменения в тексте договора, сами договора вынес в i-шки
        30/09/2005 madiyar - изменение договоров в филиалах в связи с вводом новой программы (30%)
        21/12/2005 madiyar - перекомпиляция
        22/01/2008 madiyar - изменения в договоре
        23.04.2008 alex - добавил параметры для казахского языка.
        04.06.2008 alex - изменения в договоре (валюта кредита)
        19/01/2010 galina - добавила ИИН
        21/01/2010 galina - определила переменную iin
        22/01/2010 galina -  присвоила значение ИИН
*/


{global.i}
{pk.i}

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then return.

if pkanketa.sts < "10" then do:
  message skip " Документы не оформлены !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def shared var v-ofile as char.

/* сведения о банке */
def shared var v-dol as char.
def shared var v-dolkz as char.
def shared var v-bankname as char.
def shared var v-banknamekz as char.
def shared var v-bankadres as char.
def shared var v-bankiik as char.
def shared var v-bankbik as char.
def shared var v-bankups as char.
def shared var v-bankrnn as char.
def shared var v-bankface as char.
def shared var v-bankfacekz as char.
def shared var v-bankosn as char.
def shared var v-bankosnkz as char.
def shared var v-bankpodp as char.
def shared var v-banksuff as char.
def shared var v-dognom as char.
def new shared var v-iin as char.

/* сведения об анкете - общие для всех видов кредитов */
def shared var v-city as char.
def shared var v-citykz as char.
def shared var v-datastr as char.
def shared var v-datastrkz as char.
def shared var v-name as char.

/*Валюта счета*/
def shared var v-iik as char.
def shared var v-iikval as char.
def shared var v-credval as char.


def stream v-out.

v-ofile = "dogacc.htm".

/* договор на открытие счета */

/*ИИН*/
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "iin" no-lock no-error.
if avail pkanketh and pkanketh.value1 <> "" then v-iin = pkanketh.value1.
output stream v-out to value(v-ofile).

{pkdogacc3.i}

{html-end.i "stream v-out" }
output stream v-out close.
unix silent value("cptwin " + v-ofile + " iexplore").