/* h-lcnt.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

define shared variable s-lon like lon.lon.
define variable pap as character.
define variable iem as character.
form pap format "xx"    label "Номер дополн.."
     help "Номер дополнения "
     iem format "x(30)" label "Причина......."
     help "Причина изменения"
     ln%his.stdat       label "Дата изменения"
     ln%his.rdt         label "С ............"
     ln%his.duedt       label "По  .........."
     ln%his.opnamt      label "Сумма........."
     ln%his.intrate     label "% ставка......"
     /*
     ln%his.pnlt1       label "Soda %(iz‡.).."
     ln%his.pnlt2       label "Soda %(atm.).."
     */
with overlay 2 columns row 4 side-labels centered title
"Изменение параметров по кредиту " + s-lon
frame pap.
define new shared variable rinda  as integer init 1.
define new shared temp-table wrk
               field    code     as character format "x(10)" label "Код "
               field    des      as character format "x(30)" 
               label "Наименование"
               field    ja-ne    as character format "x"     label "Выбор ".
define new shared temp-table wrk2
               field    des      as character format "x(30)".
define  variable v-f0 as integer.
define  variable v-f1 as integer.

if s-lon = ""
then return.
find lon where lon.lon = s-lon no-lock.
if lon.dam[1] = 0
then return.
find loncon where loncon.lon = s-lon exclusive-lock.
for each ln%his where ln%his.lon = s-lon and ln%his.f0 > 0 and
    ln%his.rdt <> ? and ln%his.intrate <> ? and
    (ln%his.opnamt <> ? or lon.gua = "OD") and
    ln%his.duedt <> ? no-lock by ln%his.f0:
    pap = "".
    v-f0 = index(loncon.rez-char[4],"/" +
           string(ln%his.stdat,"99/99/9999") + "&").
    if v-f0 > 0
    then do:
         pap = substring(loncon.rez-char[4],1,v-f0 - 1).
         pap = substring(pap,r-index(pap,"#") + 1).
    end.
    create wrk.
    wrk.code = string(ln%his.f0,"zz9").
    wrk.des = "Нм " + pap +
              "      Изменение " + string(ln%his.stdat,"99/99/9999").
    create wrk.
    wrk.code = string(ln%his.f0,"zz9").
    wrk.des = "   " + string(ln%his.rdt,"99/99/9999") +
              " - " + string(ln%his.duedt,"99/99/9999").
    create wrk.
    wrk.code = string(ln%his.f0,"zz9").
    wrk.des = "Сумма " + string(ln%his.opnamt,"z,zzz,zzz,zzz,zz9.99").
    create wrk.
    wrk.code = string(ln%his.f0,"zz9").
    wrk.des = "% ставка " + string(ln%his.intrate,"zzz.99").
     /*
     + " " +
              string(ln%his.pnlt1,"z.99") + " " +
              string(ln%his.pnlt2,"z.99").  */
    create wrk.
    wrk.code = string(ln%his.f0,"zz9").
    wrk.des = "-----------------------------------".
end.
run yu-chs("Список изменения параметров",2).
for each wrk:
    if wrk.ja-ne = "*"
    then v-f0 = integer(wrk.code).
    delete wrk.
end.
if lastkey = keycode("PF4")
then return.
find first ln%his where ln%his.lon = s-lon and ln%his.f0 = v-f0 no-lock.
v-f0 = index(loncon.rez-char[4],"/" + string(ln%his.stdat,"99/99/9999") + "&").
if v-f0 > 0
then do:
     pap = substring(loncon.rez-char[4],1,v-f0 - 1).
     pap = substring(pap,r-index(pap,"#") + 1).
end.
else pap = "".
v-f1 = index(loncon.rez-char[5],"/" + string(ln%his.stdat,"99/99/9999") + "&").
if v-f1 > 0
then do:
     iem = substring(loncon.rez-char[5],1,v-f1 - 1).
     iem = substring(iem,r-index(iem,"#") + 1).
end.
else iem = "".
display pap
        iem
        ln%his.stdat
        ln%his.rdt
        ln%his.duedt
        ln%his.opnamt
        ln%his.intrate
        /*
        ln%his.pnlt1
        ln%his.pnlt2 
        */
        with frame pap.
update pap iem with frame pap.
if substring(pap,2,1) = " " or length(pap) = 1
then pap = " " + substring(pap,1,1).
if trim(pap) <> ""
then do:
     if index(loncon.rez-char[4],"#" + pap) > 0
     then do:
          if index(loncon.rez-char[4],pap + "/" +
             string(ln%his.stdat,"99/99/9999")) = 0
          then do:
               bell.
               undo,retry.
          end.
     end.
     else do:
          if v-f0 > 0
          then overlay(loncon.rez-char[4],v-f0 - 2,2) = pap.
          else loncon.rez-char[4] = loncon.rez-char[4] + "#" + pap +
                                  "/" + string(ln%his.stdat,"99/99/9999") + "&".
     end.
end.
else if v-f0 > 0
then loncon.rez-char[4] = substring(loncon.rez-char[4],1,v-f0 - 3) +
                          substring(loncon.rez-char[4],v-f0 + 12).
if trim(iem) <> ""
then do:
     if v-f1 > 0
     then do:
          v-f0 = r-index(substring(loncon.rez-char[5],1,v-f1 - 1),"#").
          loncon.rez-char[5] = substring(loncon.rez-char[5],1,v-f0) + iem +
                               substring(loncon.rez-char[5],v-f1).
     end.
     else loncon.rez-char[5] = loncon.rez-char[5] + "#" + iem +
                                  "/" + string(ln%his.stdat,"99/99/9999") + "&".
end.
else if v-f1 > 0
then do:
     v-f0 = r-index(substring(loncon.rez-char[5],1,v-f1 - 1),"#").
     loncon.rez-char[5] = substring(loncon.rez-char[5],1,v-f0 - 1) +
                          substring(loncon.rez-char[5],v-f1 + 12).
end.
hide frame pap.

/*-----------------------------------------------------------------------------
  #1. 4-1-2,KredЁtu noformёЅana
  #3. Programma dod iespёju izmai‡–m kredЁtlЁgum– ievadЁt papildvienoЅa-
      n–s numuru,kas vajadzЁgs izmai‡u re¦istr–cijas atskaitё
      1.izmai‡a - var ievadЁt arЁ pagarin–Ѕanas iemeslu
  #4. Ieejas inform–cija:
      - fails lon
      - fails loncon
      - fails ln%his
      - shared mainЁgais s-lon
  #5. Izejas inform–cija:
      - fails loncon(lauks rez-char[4])
------------------------------------------------------------------------------*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #3. 1.Programmu izsauc kredЁta lЁguma numura lauci‡– nospie·ot F2
      2.Par–d–s kredЁta visu izmai‡u saraksts.Vienas reizes izmai‡as ir ar
        vienu un to paЅu kodu
      3.Nospie·ot jebkuru rindi‡u ar vajadzЁgo kodu,izvёlamies ЅЁs reizes izmai-
        ‡as
      4.Nospie·ot F1,par–d–s ekr–ni‡Ѕ ar izvёlёtaj–m izmai‡–m un lauci‡i
        papildvienoЅan–s numura un izmai‡as iemesla ievadei
      5.Pёc ievadЁЅanas un(vai) Enter nospieЅanas kursors atgrie·as kredЁtlЁguma
        numura lauci‡–

        U Z M A N § B U  ! ! !

        Lai ievadЁto inform–ciju neanulёtu,nedrЁkst lЁguma numura lauci‡– spiest
        F4.

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
