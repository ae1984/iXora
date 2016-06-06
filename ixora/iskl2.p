/* iskl2.p
 * MODULE
        “¤ «Ґ­ЁҐ Є®¬ЁААЁ©
 * DESCRIPTION
        “¤ «Ґ­ЁҐ Є®¬ЁААЁ© Ї® Є«ЁҐ­Б ¬ 
 * RUN
        ‘Ї®А®Ў ўК§®ў  ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ Ї Ю ¬ҐБЮ®ў, ЇЮЁ¬ҐЮК ўК§®ў 
 * CALLER
        s-cif.p
 * SCRIPT
        ‘ЇЁА®Є АЄЮЁЇБ®ў, ўК§Кў НИЁЕ МБ®Б Д ©«
 * INHERIT
        ‘ЇЁА®Є ўК§Кў Ґ¬КЕ ЇЮ®ФҐ¤ЦЮ
 * MENU
        1.2
 * AUTHOR
        04/08/06 nataly
 * CHANGES
*/

procedure del-excl.
  def input parameter p-aaa as char.
  def input parameter p-cif as char.
  def input parameter p-kod as char.

  find tarif2 where tarif2.str5 = p-kod and tarif2.stat = 'r' no-lock no-error.
  if avail tarif2 then do:
    
   find tarifex where tarifex.cif  = p-cif and tarifex.str5 = p-kod
                   and tarifex.stat = 'r' exclusive-lock no-error.
   if avail tarifex then do:
     for each tarifex2 where tarifex2.aaa = p-aaa and tarifex2.cif  = p-cif and tarifex2.str5 = p-kod
                   and tarifex2.stat = 'r' exclusive-lock .
           delete tarifex2.
     end.
   /* delete tarifex. */ /*­Ґ Ц¤ «ОҐ¬ Є«ЁҐ­Б , БЄ ¬®ёЦБ ЎКБЛ ЁАЄ«НГҐ­ЁО Ї® ¤ЮЦёЁ¬ Є®¬ЁААЁО¬ */
   end.

    release tarifex.
    release tarifex2.
  end.
end procedure.


define shared variable s-cif like cif.cif.
for each aaa no-lock where aaa.cif = s-cif.

   run del-excl(aaa.aaa, aaa.cif, "180").
   run del-excl(aaa.aaa, aaa.cif, "181").
   run del-excl(aaa.aaa, aaa.cif, "193").

end.

