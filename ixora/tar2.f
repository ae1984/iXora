/* tar2.f
 * MODULE
        Пвяювпке Тфръфвоопрър Ордину
 * DESCRIPTION
        Пвяпвёепке тфръфвооэ, рткхвпке тфрзедиф к ципмзкл
 * RUN
        Хтрхрч юэярюв тфръфвооэ, рткхвпке твфвоежфрю, тфкоефэ юэярюв
 * CALLER
        Хткхрм тфрзедиф, юэяэювбЁкй шжрж цвлн
 * SCRIPT
        Хткхрм хмфктжрю, юэяэювбЁкй шжрж цвлн
 * INHERIT
        Хткхрм юэяэювеоэй тфрзедиф
 * MENU
        Тефеёепы типмжрю Оепб Тфвъоэ 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        15.07.2005 saltanat - чЛМАЮЙМБ РПМС РХОЛФБ ФБТЙЖБ Й РПМОПЗП ОБЙНЕОПЧБОЙС.
        09.09.2005 saltanat - Изменила формат поля пункт тарифа.
*/

form
     tarif2.str5
                  label "Nr." format "x(4)"
     tarif2.kont validate (can-find(gl where gl.gl = tarif2.kont),
                 "Nezinamais konts")
     tarif2.punkt format "x(10)"            
     tarif2.pakalp  format "x(30)"
     tarif2.ost  format "zzzzz9" validate(tarif2.ost >= 0," >=0 !")
     tarif2.proc
     tarif2.min1 format "zzzzz9"
     tarif2.max1 format "zzzzz9"
     with overlay  row 3 25 down centered 
     title "Тарифы"  frame tar2 .
