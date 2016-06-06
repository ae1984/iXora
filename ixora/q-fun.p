/* q-fun.p
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

/* q-fun.p
*/

{mainhead.i MMQRY}

def var vbal like jl.dam.
define variable c-crc as character.
define variable v-jhin like jh.jh.
define variable v-jhout like jh.jh.
define variable kas as character.

form jl.jdt jl.crc jl.dam jl.cam jl.jh jl.who
     jl.rem[1] label "Примечания" at 10
     with frame jl down centered row 14 NO-BOX.

form fun.fun    label  "Номер сделки" 
     kas format "x(16)"  no-label skip
     fun.rdt    label  "Дата регистр"
     fun.duedt  label  "Дата закрыт." 
     fun.trm    label  "К-во дней..." skip
     fun.gl     label  "Гл.Книга...." 
     gl.des  no-label  format "x(24)" skip
     fun.bank   label  "Банк........" skip
     fun.intrate label "% ставка...." format "zzz9.9999"
     fun.itype  label  "Тип %......."
     c-crc      label  "Валюта......"
     fun.tbank  label  "Банк........" skip
     fun.amt    label  "Сумма......."
     fun.interest format "z,zzz,zzz,zzz,zz9.99"
                label  "Сумма проц.." skip    
     fun.dam[1] label  "Дебет......."
     fun.dam[2] label  "Дебет......." skip
     fun.cam[1] label  "Кредит......"
     fun.cam[2] label  "Кредит......" skip
     fun.dfb    label  "Ностро......"
     fun.crbank label  "Контрагент.." skip
     fun.remin  label  "Вход.перев.."
     fun.remout label  "Исход.перев." skip
     fun.jh2    label  "Вход.транз.."
     fun.jh1    label  "Исход.транз."
     fun.geo    label  "Гео........." format "xxx"
     fun.zalog  label  "Залог ?....." 
     fun.lonsec label  "Обеспечение."
     fun.risk   label  "Риск........"
     fun.penny  label  "Пени........"
     with frame fun row 3 no-box 2 col.
view frame fun.

main: repeat:
  prompt-for fun.fun with frame fun.
  find fun using fun.fun no-error.
  if not available fun
    then do:
      bell.
      {mesg.i 0230}.
      undo, retry.
    end.
  find gl where gl.gl eq fun.gl no-lock.
  if gl.type = "A"
  then kas = "( Кредит ) " + string(fun.grp,">99").
  else if gl.type = "L"
  then kas = "( Депозит ) " + string(fun.grp,">99").
  else kas = "( ??? )".
  vbal = fun.cam[1] - fun.dam[1].
  find crc where crc.crc = fun.crc no-lock.
  c-crc = string(crc.crc,"z9") + " " + crc.code.
  disp fun.fun kas fun.rdt fun.duedt fun.trm fun.gl gl.des
       fun.bank fun.intrate fun.itype c-crc
       fun.amt  fun.interest fun.dam[1] fun.dam[2]
       fun.cam[1] fun.cam[2] fun.dfb fun.crbank fun.tbank
       fun.remin fun.remout fun.jh2 fun.jh1
       fun.geo fun.zalog fun.lonsec fun.risk fun.penny 
       with frame fun.

  clear frame jl all no-pause.
  for each jl where jl.acc eq fun.fun no-lock by jl.jdt:
    display jl.jdt jl.crc jl.dam jl.cam jl.jh jl.who jl.rem[1]
            with frame jl.
    down with frame jl.
  end.
end. /* main */
