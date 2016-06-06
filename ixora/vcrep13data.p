/* vcrep13data.p
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
*/

/* vcrep-13t.p - Валютный контроль 
Приложение 13 - все платежи за месяц по контрактам, где есть рег. свид-ва
Сборка во временную таблицу

  04.11.2002 nadejda создан

*/

def input parameter p-vcbank as char.
def input parameter p-depart as integer.
def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def var v-name as char.
def var v-rnn as char.
def var v-partner as char.


def shared temp-table t-docs 
  field dndate like vcdocs.dndate
  field sum like vcdocs.sum
  field docs like vcdocs.docs
  field dnrslc like vcrslc.dnnum
  field name like ast.cif.name
  field partner like vcpartners.name
  field knp like vcdocs.knp
  field codval as integer
  field ctnum like vccontrs.ctnum
  field ctdate like vccontrs.ctdate
  field rnn as char format "999999999999"
  field strsum as char
  index main is primary dndate sum docs.

for each vccontrs where vccontrs.bank = p-vcbank and 
      can-find(first vcrslc where vcrslc.contract = vccontrs.contract and 
          vcrslc.dntype = "21" no-lock) and 
      can-find(first vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "03" and 
          year(vcdocs.dndate) = v-god and month(vcdocs.dndate) = v-month no-lock) and
      if p-depart = 0 then true else 
           can-find(ast.cif where (ast.cif.cif = vccontrs.cif) and 
           (integer(ast.cif.jame) mod 1000 = p-depart) no-lock)
      no-lock:
  find last vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "21" 
       no-lock no-error.
  find ast.cif where ast.cif.cif = vccontrs.cif no-lock no-error.
  v-name = trim(trim(ast.cif.name) + " " + trim(ast.cif.prefix)).
  if not trim(ast.cif.jss) begins "0000" then v-rnn = trim(ast.cif.jss).
  else v-rnn = "".

  find vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
  if avail vcpartner then 
    v-partner = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
  else v-partner = "".

  for each vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "03" and 
          year(vcdocs.dndate) = v-god and month(vcdocs.dndate) = v-month no-lock:
    find ast.ncrc where ast.ncrc.crc = vcdocs.pcrc no-lock no-error.
    create t-docs.
    assign t-docs.dndate = vcdocs.dndate
           t-docs.sum = vcdocs.sum
           t-docs.strsum = trim(string(vcdocs.sum, ">>>>>>>>>>>>>>9.99"))
           t-docs.docs = vcdocs.docs
           t-docs.dnrslc = vcrslc.dnnum
           t-docs.name = v-name
           t-docs.partner = v-partner
           t-docs.knp = vcdocs.knp
           t-docs.codval = ast.ncrc.stn
           t-docs.ctnum = vccontrs.ctnum
           t-docs.ctdate = vccontrs.ctdate
           t-docs.rnn = v-rnn.
    if vcdocs.payret then do:
      t-docs.sum = - t-docs.sum.
      t-docs.strsum = "-" + t-docs.strsum.
    end.
  end.
end.

