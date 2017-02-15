--XXMU_HR_UTILS3_PK
--XXMU_HR_UTILS4_PK

/*BEGIN
--mo_global.set_policy_context('S',4346);
fnd_global.apps_initialize (  12186,  50645,	800);  --GM_CO_HR_SUPER_USUARIO
END;*/

--XXMU_PAY_ABSENCE_DATES_DIST  lookup
--XXMU_PAY_ABSENCE_DATES_DIST  flexfield (Common Lookups)
--XXMU_PAY_INPUTS_NAME         value set

--XX_DEBUG xx_debug_pk.debug('...TEST...');
SELECT *
  FROM xx_debug_messages
 WHERE debug_sequence >= 988755510
   AND  creation_date > SYSDATE -1
     ;



SELECT DECODE(NVL(LENGTH('&p_date'),0),0,SYSDATE, TO_DATE('2017/01/20', 'YYYY/MM/DD')) FROM dual;

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            --@ediaz20170118>>
            Execute_Entry_Update_Statement(pn_in_absence_attendance_id => p_absence_attendance_id
                                          ,pv_in_element_name          => vv_elemento_ausencia --'I_1600'
                                          ,pv_in_global_concept        => NULL
                                          ,pd_in_init_real_date        => NULL
                                          ,pd_in_final_real_date       => NULL
                                          ,pd_in_init_date             => NULL
                                          ,pd_in_final_date            => NULL);
            --@ediaz20170118<<

            --@ediaz20170118>>>
            xx_debug_pk.debug('**ELEMENT '||v_element_name);
            xx_debug_pk.debug('*init_date: '||v_start_date);
            xx_debug_pk.debug('*final_date: '||fffunc.add_days(v_start_date, v_dias_ingresar-1));
            Execute_Update_Statement(pn_in_absence_attendance_id    => P_ABSENCE_ATTENDANCE_ID
                                    ,pv_in_element_name             => v_element_name
                                    ,pv_in_datetrack_update_mode    => 'CORRECTION'
                                    ,pd_in_effective_date           => v_start_date
                                    ,pn_in_business_group_id        => v_business_group_id
                                    ,pn_in_element_entry_id         => v_element_entry_id
                                    ,pn_inout_object_version_number => v_object_version_number
                                    ,pv_in_global_concept           => vv_elemento_ausencia
                                    ,pv_in_creator_type             => 'A'
                                    ,pd_in_init_real_date           => NULL
                                    ,pd_in_final_real_date          => NULL
                                    ,pd_in_init_date                => v_start_date
                                    ,pd_in_final_date               => fffunc.add_days(v_start_date, v_dias_ingresar-1));  
            --@ediaz20170118<<<

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
9585336
/*BEGIN
  XXMU_HR_UTILS3_PK.Execute_Update_Statement(pn_in_absence_attendance_id => 9585336
                                ,pv_in_element_name          => 'I_1600'
                                ,pv_in_global_concept        => NULL
                                ,pd_in_init_real_date        => NULL
                                ,pd_in_final_real_date       => NULL
                                ,pd_in_init_date             => NULL
                                ,pd_in_final_date            => NULL);
END;*/

I_1680_FECHA_INICIO_REAL Futuro2
D_2110_FECHA_INICIAL     Futuro1
D_2110_FECHA_FINAL       UNDEFINED
I_1684_FECHA_INICIO_REAL FECHA
D_2124_FECHA_INICIAL     FECHA_INICIAL
D_2124_FECHA_FINAL       FECHA FINAL
I_1600_FECHA_INICIO_REAL Futuro2
A_0600_FECHA_INICIAL     Fecha Inicial
A_0600_FECHA_FINAL       'Fecha Final'--
A_0740_FECHA_INICIAL     Fecha Inicial
A_0740_FECHA_FINAL       'Fecha Final'--
A_0740_CONCEPTO_GLOBAL   Concepto_Global          
I_1620_FECHA_INICIO_REAL Futuro2
A_0620_FECHA_INICIAL     FECHA INICIAL
A_0620_FECHA_FINAL       FECHA_FINAL
I_1625_FECHA_INICIO_REAL Futuro2
A_0625_FECHA_INICIAL     Fecha Inicial
A_0625_FECHA_FINAL       'Fecha Final'--
I_1650_FECHA_INICIAL     FECHA INICIAL
A_0650_FECHA_INICIAL     Fecha inicial
A_0650_FECHA_FINAL       'Fecha Final'--
--A_0740_FECHA_INICIAL     Fecha Inicial
--A_0740_FECHA_FINAL       Fecha Final--
I_1690_FECHA_INICIAL     Futuro2
A_0660_FECHA_INICIAL     Fecha Inicial
A_0660_FECHA_FINAL       'Fecha Final'--
I_1720_FECHA_INICIAL     Futuro2
A_0690_FECHA_INICIAL     Fecha Inicial
A_0690_FECHA_FINAL       'Fecha Final'--
I_1675_FECHA_INICIAL     FECHA INCIAL
A_0775_FECHA_INICIAL     Fecha Inicial
A_0775_FECHA_FINAL       'Fecha Final'--
A_1730_FECHA_INICIO_REAL Fecha
I_0911_FECHA_INICIAL     UNDEFINED
I_0911_FECHA_FINAL       UNDEFINED
A_0780_FECHA_INICIAL     Fecha
A_0780_FECHA_FINAL       Futuro2
;

SELECT pet.element_name
      ,pet.reporting_name
      ,pet.description
      ,piv.name AS input_name
      ,piv.uom
FROM   pay_element_types_f pet
      ,pay_input_values_f piv
WHERE  1 = 1
AND    pet.element_name LIKE 'I_1680'
--'A_0660'--'A_0780' --'I_0911' --'A_1730'
--'A_0775' --'I_1675' --'A_0690' --'I_1720' --'A_0660' --'I_1690' --'A_0740' --'A_0650' --'I_1650' --'A_0625'--'I_1625'
--'A_0620' --'I_1620'--'A_0740' --'A_0600'--'I_1600'--'D_2124' --'I_1684' --'D_2110' --'I_1600'
AND    piv.element_type_id = pet.element_type_id
;

--FECHA_INICIO_REAL -> Tomar F.Inicial desde Pantalla Standard
--FECHA_FINAL_REAL  -> Tomar F.Fin     desde Pantalla Standard
--[D_####]

--VALIDATE LOOKUP (ELEMENT/INPUT)
--    p_elemento_ausencia --> 'I_1680'
--    GET_ENTRIES_UPDATE_STATEMENT
--      ->,p_input_value_id3       => 973 ,p_entry_value3  => '19-ENE-2017'


SELECT XXMU_HR_UTILS3_PK.Get_Entry_Update_Statement(pv_element_name => 'I_1680'
                                                   ,pn_absence_attendance_id => 9586346
                                                   ,pv_in_global_concept => 'I_1680'
                                                   ,pd_in_init_real_date => NULL
                                                   ,pd_in_final_real_date => NULL
                                                   ,pd_in_init_date => NULL
                                                   ,pd_in_final_date => NULL
                                                   )
  FROM DUAL;

SELECT NVL2(piv_init_real.display_sequence,',p_input_value_id'||piv_init_real.display_sequence||' => '||piv_init_real.input_value_id
                                         ||',p_entry_value'||piv_init_real.display_sequence||' => '||TO_CHAR(dcv.init_real_date, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'),NULL)
     ||NVL2(piv_final_real.display_sequence,',p_input_value_id'||piv_final_real.display_sequence||' => '||piv_final_real.input_value_id
                                         ||',p_entry_value'||piv_final_real.display_sequence||' => '||TO_CHAR(dcv.final_real_date, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'),NULL)
     ||NVL2(piv_init.display_sequence,',p_input_value_id'||piv_init.display_sequence||' => '||piv_init.input_value_id
                                    ||',p_entry_value'||piv_init.display_sequence||' => '||TO_CHAR(dcv.init_date, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'),NULL)
     ||NVL2(piv_final.display_sequence,',p_input_value_id'||piv_final.display_sequence||' => '||piv_final.input_value_id
                                     ||',p_entry_value'||piv_final.display_sequence||' => '||TO_CHAR(dcv.final_date, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'),NULL)
     ||NVL2(piv_global_concept.display_sequence,',p_input_value_id'||piv_global_concept.display_sequence||' => '||piv_global_concept.input_value_id
                                     ||',p_entry_value'||piv_global_concept.display_sequence||' => '||SUBSTR(lkp.element_name,1,6),NULL)
      ----
      ,NVL2(piv_init_real.display_sequence,',p_input_value_id'||piv_init_real.display_sequence||' => '||piv_init_real.input_value_id
                                         ||',p_entry_value'||piv_init_real.display_sequence||' => '||TO_CHAR(dcv.init_real_date, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'),NULL)
      ,NVL2(piv_final_real.display_sequence,',p_input_value_id'||piv_final_real.display_sequence||' => '||piv_final_real.input_value_id
                                         ||',p_entry_value'||piv_final_real.display_sequence||' => '||TO_CHAR(dcv.final_real_date, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'),NULL)
      ,NVL2(piv_init.display_sequence,',p_input_value_id'||piv_init.display_sequence||' => '||piv_init.input_value_id
                                    ||',p_entry_value'||piv_init.display_sequence||' => '||TO_CHAR(dcv.init_date, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'),NULL)
      ,NVL2(piv_final.display_sequence,',p_input_value_id'||piv_final.display_sequence||' => '||piv_final.input_value_id
                                     ||',p_entry_value'||piv_final.display_sequence||' => '||TO_CHAR(dcv.final_date, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'),NULL)
      ,NVL2(piv_global_concept.display_sequence,',p_input_value_id'||piv_global_concept.display_sequence||' => '||piv_global_concept.input_value_id
                                     ||',p_entry_value'||piv_global_concept.display_sequence||' => '||SUBSTR(lkp.element_name,1,6),NULL)
      -----
      ,lkp.element_type_id
      ,lkp.element_name
      ,lkp.init_real
      ,piv_init_real.input_value_id
      ,piv_init_real.display_sequence
      ,piv_init_real.name AS input_name
      ,piv_init_real.uom
      ,dcv.init_real_date
      ,lkp.final_real
      ,piv_final_real.input_value_id
      ,piv_final_real.display_sequence
      ,piv_final_real.name AS input_name
      ,piv_final_real.uom
      ,dcv.final_real_date
      ,lkp.init
      ,piv_init.input_value_id
      ,piv_init.display_sequence
      ,piv_init.name AS input_name
      ,piv_init.uom
      ,dcv.init_date
      ,lkp.final
      ,piv_final.input_value_id
      ,piv_final.display_sequence
      ,piv_final.name AS input_name
      ,piv_final.uom
      ,dcv.final_date
      ,lkp.global_concept
      ,piv_global_concept.input_value_id
      ,piv_global_concept.display_sequence
      ,piv_global_concept.name AS input_name
      ,piv_global_concept.uom
      ,SUBSTR(lkp.element_name,1,6) concept_code
FROM   (SELECT pet.element_type_id
              ,pet.element_name
              ,flv.attribute1 init_real
              ,flv.attribute2 final_real
              ,flv.attribute3 init
              ,flv.attribute4 final
              ,flv.attribute5 global_concept
        FROM   fnd_lookup_values flv
              ,pay_element_types_f pet
        WHERE  flv.lookup_type = 'XXMU_PAY_ABSENCE_DATES_DIST'
          AND  flv.language = USERENV('LANG')
          AND  pet.element_name(+) LIKE flv.lookup_code
          AND  flv.lookup_code LIKE 'I_1600' --'A_0740' --'A_0600' --'A_0740' --'A_0750'
          ) lkp
      ,(SELECT paa.date_start init_real_date
              ,paa.date_end final_real_date
              ,TO_DATE(PAA.ATTRIBUTE4,'YYYY/MM/DD HH24:MI:SS') init_date
              ,TO_DATE(PAA.ATTRIBUTE5,'YYYY/MM/DD HH24:MI:SS') final_date
          FROM per_absence_attendances_v paa
         WHERE paa.absence_attendance_id = 9584347) dcv
      ,pay_input_values_x piv_init_real
      ,(SELECT 
          FROM pay_input_values_x piv
         WHERE piv_init_real.element_type_id(+) = lkp.element_type_id
           AND piv_init_real.input_value_id(+) = lkp.init_real)
      ,pay_input_values_x piv_final_real
      ,pay_input_values_x piv_init
      ,pay_input_values_x piv_final
      ,pay_input_values_x piv_global_concept
WHERE  piv_init_real.element_type_id(+) = lkp.element_type_id
  AND  piv_init_real.input_value_id(+) = lkp.init_real
  AND  piv_final_real.element_type_id(+) = lkp.element_type_id
  AND  piv_final_real.input_value_id(+) = lkp.final_real
  AND  piv_init.element_type_id(+) = lkp.element_type_id
  AND  piv_init.input_value_id(+) = lkp.init
  AND  piv_final.element_type_id(+) = lkp.element_type_id
  AND  piv_final.input_value_id(+) = lkp.final
  AND  piv_global_concept.element_type_id(+) = lkp.element_type_id
  AND  piv_global_concept.input_value_id(+) = lkp.global_concept
  ;
  
SELECT piv.input_value_id, ROWNUM AS seq
FROM  pay_element_entries_f pee
     ,pay_element_links_f pel
     ,pay_link_input_values_f piv
WHERE pee.element_entry_id = 18369555
AND   pel.element_link_id = pee.element_link_id
AND   piv.element_link_id = pel.element_link_id
ORDER BY piv.input_value_id
;

SELECT 'FECHA_INICIO_REAL' AS DATE_CODE
              ,paa.date_start AS DATE_VALUE
          FROM per_absence_attendances_v paa
         WHERE paa.absence_attendance_id = 9584347


SELECT paa.date_start init_real_date
      ,paa.date_end final_real_date
      ,TO_DATE(PAA.ATTRIBUTE4,'YYYY/MM/DD HH24:MI:SS') init_date
      ,TO_DATE(PAA.ATTRIBUTE5,'YYYY/MM/DD HH24:MI:SS') final_date
FROM   per_absence_attendances_v paa
WHERE  paa.absence_attendance_id = 9584347
;

--API HOOK
/*BEGIN
  hr_api_user_hooks_utility.create_hooks_one_module(1731);
END;*/

--FND_LOOKUP_VALUE (XXMU_PAY_ABSENCE_DATES_DIST)
SELECT REPLACE(flv.meaning, '&p_element_name'||'_', '') DATE_TYPE
      ,pet.element_name
      ,piv.name input_name
      ,piv.input_value_id
      ,piv.UOM
  FROM fnd_lookup_values flv
      ,pay_element_types_f pet
      ,pay_input_values_f piv
 WHERE flv.lookup_type = 'XXMU_PAY_ABSENCE_DATES_DIST'
   AND flv.language = USERENV('LANG')
   AND flv.lookup_code LIKE '&p_element_name'||'%'
   AND pet.element_name LIKE '&p_element_name'
   AND piv.element_type_id = pet.element_type_id
   AND piv.name = flv.tag
  ;


SELECT flv.lookup_code, flv.meaning, flv.tag, flv.attribute1, flv.attribute2, flv.attribute3, flv.attribute4
FROM   fnd_lookup_values flv
WHERE  flv.lookup_type = 'XXMU_PAY_ABSENCE_DATES_DIST'
  AND  flv.language = USERENV('LANG')
-- AND  flv.lookup_code LIKE 'I_1680%'
 ORDER BY flv.lookup_code
--FOR UPDATE
  ;

SELECT pet.element_name
      ,piv.name
      ,piv.input_value_id
      ,piv.display_sequence
      ,piv.*
FROM  pay_element_types_x pet
     ,pay_input_values_x piv
WHERE  pet.element_name = 'I_1600' --'A_0740' -- 
AND    piv.element_type_id = pet.element_type_id
;

SELECT XXMU_HR_UTILS3_PK.Get_Sequence_By_Input(1622) FROM DUAL;

SELECT seq
  FROM (SELECT input_value_id, ROWNUM AS seq
        FROM (SELECT piv2.input_value_id
                FROM pay_input_values_x piv
                    ,pay_input_values_x piv2
               WHERE piv.input_value_id = 1622
                 AND piv2.element_type_id = piv.element_type_id
               ORDER BY piv2.input_value_id))
WHERE input_value_id = 1622
;

SELECT *
FROM   pay_link_input_values_f l
WHERE  l.element_link_id = 66800
;


SELECT pev.*
FROM   pay_element_entries_f pee
     , pay_element_entry_values_f pev
     , pay_element_entr
WHERE pee.element_entry_id = 18369555
 AND  pev.element_entry_id = pee.element_entry_id
;
--GET_ELEMENT_ENTRY_INFO
/*
BEGIN
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_LANGUAGE= SPANISH';
END;

/*
DECLARE
  P_ABSENCE_ATTENDANCE_ID   pay_element_entries_f.creator_id%TYPE := 9592359; --9586350; --9584347; --9584338;
  P_ELEMENT_NAME            pay_element_types_f.element_name%TYPE := 'I_1675'; --'I_1680'; --'A_0740'; --
  X_DATETRACK_UPDATE_MODE   pay_element_types_f.element_name%TYPE;
  X_EFFECTIVE_DATE          pay_element_entries_f.effective_start_date%TYPE;
  X_BUSINESS_GROUP_ID       pay_element_types_f.business_group_id%TYPE;
  X_ELEMENT_ENTRY_ID        pay_element_entries_f.element_entry_id%TYPE;
  vn_object_version_number  pay_element_entries_f.object_version_number%TYPE;
  vd_effective_start_date   pay_element_entries_f.effective_start_date%TYPE;
  vd_effective_end_date     pay_element_entries_f.effective_end_date%TYPE;
  vn_CREATOR_ID             pay_element_entries_f.creator_id%TYPE;
  X_CREATOR_TYPE            pay_element_entries_f.creator_type%TYPE;
  X_STATUS                  pay_element_types_f.element_name%TYPE;
  v_warnings                BOOLEAN;

  SQL_STATEMENT             VARCHAR2(4000);
  SQL_ENTRIES               VARCHAR2(4000);

BEGIN
  XXMU_HR_UTILS3_PK.Get_Element_Entry_Info(
                      P_ABSENCE_ATTENDANCE_ID
                     ,P_ELEMENT_NAME
                     ,X_DATETRACK_UPDATE_MODE
                     ,X_EFFECTIVE_DATE
                     ,X_BUSINESS_GROUP_ID
                     ,X_ELEMENT_ENTRY_ID
                     ,vn_object_version_number
                     ,vd_effective_start_date
                     ,vd_effective_end_date
                     ,vn_creator_id
                     ,X_CREATOR_TYPE
                     ,X_STATUS
                   );
  DBMS_OUTPUT.PUT_LINE('P_ABSENCE_ATTENDANCE_ID: '||P_ABSENCE_ATTENDANCE_ID);
  DBMS_OUTPUT.PUT_LINE('P_ELEMENT_NAME: '||P_ELEMENT_NAME);
  DBMS_OUTPUT.PUT_LINE('X_DATETRACK_UPDATE_MODE: '||X_DATETRACK_UPDATE_MODE);
  DBMS_OUTPUT.PUT_LINE('X_EFFECTIVE_DATE: '||X_EFFECTIVE_DATE);
  DBMS_OUTPUT.PUT_LINE('X_BUSINESS_GROUP_ID: '||X_BUSINESS_GROUP_ID);
  DBMS_OUTPUT.PUT_LINE('X_ELEMENT_ENTRY_ID: '||X_ELEMENT_ENTRY_ID);
  DBMS_OUTPUT.PUT_LINE('X_OBJECT_VERSION_NUMBER: '||vn_object_version_Number);
  DBMS_OUTPUT.PUT_LINE('X_EFFECTIVE_START_DATE: '||vd_effective_start_date);
  DBMS_OUTPUT.PUT_LINE('X_EFFECTIVE_END_DATE: '||vd_effective_end_date);
  DBMS_OUTPUT.PUT_LINE('X_CREATOR_ID: '||VN_CREATOR_ID);
  DBMS_OUTPUT.PUT_LINE('X_CREATOR_TYPE: '||X_CREATOR_TYPE);
  DBMS_OUTPUT.PUT_LINE('X_STATUS: '||X_STATUS);
  
  SQL_ENTRIES := XXMU_HR_UTILS3_PK.Get_Entry_Update_Statement(pv_in_element_name => P_ELEMENT_NAME --'I_1680'
                                                             ,pn_in_absence_attendance_id => P_ABSENCE_ATTENDANCE_ID
                                                             ,pv_in_global_concept => P_ELEMENT_NAME --'I_1680'
                                                             ,pd_in_init_real_date => NULL
                                                             ,pd_in_final_real_date =>  NULL
                                                             ,pd_in_init_date => NULL \*TO_DATE('2017/01/01', 'YYYY/MM/DD')*\
                                                             ,pd_in_final_date => NULL \*TO_DATE('2017/01/01', 'YYYY/MM/DD')*\
                                                             );
  
  SQL_STATEMENT := 'BEGIN apps.pay_element_entry_api.update_element_entry(
                                              p_datetrack_update_mode => '''||X_DATETRACK_UPDATE_MODE
                                        ||''',p_effective_date        => TO_DATE('''||TO_CHAR(X_EFFECTIVE_DATE, 'YYYY/MM/DD')||''', ''YYYY/MM/DD'')'
                                          ||',p_business_group_id     => '||X_BUSINESS_GROUP_ID
                                          ||',p_element_entry_id      => '||X_ELEMENT_ENTRY_ID
                                          ||',p_object_version_number => :pn_object_version_number
                                             ,p_effective_start_date  => :pd_effective_start_date
                                            ,p_effective_end_date     => :pd_effective_end_date
                                            ,p_update_warning         => :v_warnings
                                            ,p_creator_id             => '||p_absence_attendance_id
                                         ||',p_creator_type           => ''A''
                                         '||SQL_ENTRIES
                                          ||'); END;';

  dbms_output.put_line('SQL_STATEMENT: '||SQL_STATEMENT);  
  dbms_output.put_line('SQL_ENTRIES: '||SQL_ENTRIES);  
  --EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_LANGUAGE= AMERICAN';
  --EXECUTE IMMEDIATE SQL_STATEMENT USING IN OUT vn_object_version_number, OUT vd_effective_start_date, OUT vd_effective_end_date, OUT v_warnings;
  
EXCEPTION 
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
*/

SELECT XXMU_HR_UTILS3_PK.Get_Entry_Update_Statement(pv_in_element_name => 'A_0740'
                                                   ,pn_in_absence_attendance_id => 9584347
                                                   ,pv_in_global_concept => 'I_1600'
                                                   ,pd_in_init_real_date => NULL
                                                   ,pd_in_final_real_date =>  NULL
                                                   ,pd_in_init_date => TO_DATE('2017/01/01', 'YYYY/MM/DD')
                                                   ,pd_in_final_date => TO_DATE('2017/01/01', 'YYYY/MM/DD'))
  FROM dual;

--*/

/*BEGIN
  apps.pay_element_entry_api.update_element_entry(
                                              p_datetrack_update_mode => 'CORRECTION',p_effective_date        => '16-ENE-2017',p_business_group_id     => 81,p_element_entry_id      => 18368603,p_object_version_number => 3,p_effective_start_date  => '16-ENE-2017',p_effective_end_date    => '31-ENE-2017',p_update_warning        => :v_warnings ,p_input_value_id3      => 973,p_entry_value3         => '18-ENE-2017');
EXCEPTION 
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;*/

apps.pay_element_entry_api.update_element_entry(p_datetrack_update_mode => 'CORRECTION'
                                               ,p_effective_date        => 
                                               ,p_business_group_id     => 81
                                               ,p_element_entry_id      => 18368603
                                               ,p_object_version_number => 3  --IN OUT
                                               ,p_effective_start_date  => '16-ENE-2017' --OUT
                                               ,p_effective_end_date    => '31-ENE-2017' --OUT
                                               ,p_update_warning        => v_warnings
                                               ,p_input_value_id3       => 973
                                               ,p_entry_value3          => '17-ENE-2017')
--
P_ABSENCE_ATTENDANCE_ID: 9584345
P_ELEMENT_NAME: I_1600
X_DATETRACK_UPDATE_MODE: CORRECTION
X_EFFECTIVE_DATE: 01/01/17
X_BUSINESS_GROUP_ID: 81
X_ELEMENT_ENTRY_ID: 18368590
X_OBJECT_VERSION_NUMBER: 2
X_EFFECTIVE_START_DATE: 01/01/17
X_EFFECTIVE_END_DATE: 15/01/17
X_CREATOR_TYPE: A
X_STATUS: OK



--
/*DECLARE  
  P_ABSENCE_ATTENDANCE_ID   pay_element_entries_f.creator_id%TYPE := 9584345;
  P_ELEMENT_NAME            pay_element_types_f.element_name%TYPE := 'I_1600';
  X_DATETRACK_UPDATE_MODE   pay_element_types_f.element_name%TYPE := 'CORRECTION';
  X_EFFECTIVE_DATE          pay_element_entries_f.effective_start_date%TYPE := TO_DATE('01/01/2017', 'DD/MM/YYYY');
  X_BUSINESS_GROUP_ID       pay_element_types_f.business_group_id%TYPE := 81;
  X_ELEMENT_ENTRY_ID        pay_element_entries_f.element_entry_id%TYPE := 18368603;
  X_OBJECT_VERSION_NUMBER   pay_element_entries_f.object_version_number%TYPE := 1;
  X_EFFECTIVE_START_DATE    pay_element_entries_f.effective_start_date%TYPE := TO_DATE('01/01/2017', 'DD/MM/YYYY');
  X_EFFECTIVE_END_DATE      pay_element_entries_f.effective_end_date%TYPE := TO_DATE('15/01/2017', 'DD/MM/YYYY');
  v_warnings              BOOLEAN;
  
BEGIN
  apps.pay_element_entry_api.update_element_entry(p_datetrack_update_mode => X_DATETRACK_UPDATE_MODE
                                                 ,p_effective_date        => X_EFFECTIVE_DATE
                                                 ,p_business_group_id     => X_BUSINESS_GROUP_ID
                                                 ,p_element_entry_id      => X_ELEMENT_ENTRY_ID
                                                 ,p_object_version_number => X_OBJECT_VERSION_NUMBER
                                                 ,p_effective_start_date  => X_EFFECTIVE_START_DATE
                                                 ,p_effective_end_date    => X_EFFECTIVE_END_DATE
                                                 ,p_update_warning        => v_warnings
                                                 ,p_creator_id            => P_ABSENCE_ATTENDANCE_ID
                                                 ,p_creator_type          => X_CREATOR_TYPE);
END;*/
--*/
SELECT TO_DATE('11/01/2017', 'DD/MM/YYYY') FROM dual;

/*DECLARE
  -- DT API Out Variables
   p_element_entry_id NUMBER := 18368603;
   lb_correction             boolean;                       
   lb_update                 boolean;                       
   lb_upover                 boolean;                        
   lb_upchin                 boolean; 
BEGIN
     dt_api.find_dt_upd_modes
      ( p_effective_date        =>  to_date('16/01/2017', 'DD/MM/YYYY')
      , p_base_table_name       =>  'PAY_ELEMENT_ENTRIES_F'
      , p_base_key_column       =>  'ELEMENT_ENTRY_ID'
      , p_base_key_value        =>  p_element_entry_id
      , p_correction            =>  lb_correction
      , p_update                =>  lb_update
      , p_update_override       =>  lb_upover
      , p_update_change_insert  =>  lb_upchin
      );  

    DBMS_OUTPUT.PUT_LINE('lb_correction: '||sys.diutil.bool_to_int(lb_correction));  
    DBMS_OUTPUT.PUT_LINE('lb_update: '||sys.diutil.bool_to_int(lb_update));
    DBMS_OUTPUT.PUT_LINE('lb_upover: '||sys.diutil.bool_to_int(lb_upover));
    DBMS_OUTPUT.PUT_LINE('lb_upchin: '||sys.diutil.bool_to_int(lb_upchin));
END;*/


     SELECT 'CORRECTION'               --DATETRACK_UPDATE_MODE
            ,ee.effective_start_date   --EFFECTIVE_DATE
            ,pet.business_group_id     --BUSINESS_GROUP_ID
            ,ee.element_entry_id       --ELEMENT_ENTRY_ID
            ,ee.object_version_number  --OBJECT_VERSION_NUMBER
            ,ee.effective_start_date   --EFFECTIVE_START_DATE
            ,ee.effective_end_date     --EFFECTIVE_END_DATE
            ,'A'                       --CREATOR_TYPE
            ,EE.*
      /*INTO   pv_out_datetrack_update_mode
            ,pd_out_effective_date
            ,pn_out_business_group_id
            ,pn_out_element_entry_id
            ,pn_out_object_version_number
            ,pd_out_effective_start_date
            ,pd_out_effective_end_date
            ,pv_out_creator_type*/
      FROM   pay_element_entries_f ee
            ,pay_element_types_f pet
      WHERE  pet.element_type_id = ee.element_type_id
        AND  ee.creator_id = 9584347 --pn_in_absence_attendance_id
        AND  pet.element_name = 'A_0740' --pv_in_element_name
        ;


/*DECLARE
  p_element_entry_id NUMBER := 18368603;
  v_warnings              BOOLEAN;
  v_date DATE := TO_DATE('16/01/2017', 'DD/MM/YYYY');
  p_start_date DATE := TO_DATE('16/01/2017', 'DD/MM/YYYY');
  p_end_date DATE := TO_DATE('31/01/2017', 'DD/MM/YYYY');
  p_object_version_number   pay_element_entries_f.object_version_number%TYPE := 2;
BEGIN

  apps.pay_element_entry_api.update_element_entry(p_datetrack_update_mode => 'CORRECTION'
                                                 ,p_effective_date        => v_date
                                                 ,p_business_group_id     => '81'
                                                 ,p_element_entry_id      => p_element_entry_id
                                                 ,p_object_version_number => p_object_version_number
                                                 ,p_effective_start_date  => p_start_date
                                                 ,p_effective_end_date    => p_end_date
                                                 ,p_update_warning        => v_warnings
                                                 --,p_creator_id            => 9584346
                                                 --,p_creator_type          => 'A'
                                                 --,p_input_value_id5       => 1622
                                                 --,p_entry_value5          => '11-ENE-2017' --TO_DATE('11/01/2017', 'DD/MM/YYYY')
                                                 ,p_input_value_id3      => 973
                                                 ,P_ENTRY_VALUE3         => '17-ENE-2017' --TO_DATE('17/01/2017', 'DD/MM/YYYY')
                                                 );

  dbms_output.put_line('v_warning: '||sys.diutil.bool_to_int(v_warnings));
END;*/

with t as (select 'aaaa bbbb cccc dddd eeee ffff aaaa' as txt from dual)
-- end of sample data
select DISTINCT REGEXP_SUBSTR (txt, '[^[:space:]]+', 1, level) as word
from t
CONNECT BY LEVEL <= LENGTH(regexp_replace(txt,'[^[:space:]]+'))+1;

SELECT pee.element_entry_id
      ,pee.creator_id
      ,pet.element_name
      ,piv.input_value_id
      ,piv.name
      ,piv.display_sequence
  FROM pay_element_entries_f  pee
      ,pay_element_types_f pet
      ,pay_input_values_f piv
 WHERE pee.element_entry_id = 18368603
   AND pet.element_type_id = pee.element_type_id
   AND piv.element_type_id = pet.element_type_id
 ;

SELECT 'FECHA_INICIO_REAL' AS DATE_CODE
      ,paa.date_start AS DATE_VALUE
  FROM per_absence_attendances_v paa
 WHERE paa.absence_attendance_id = 9298325 --9584338
   UNION 
SELECT 'FECHA_INICIAL'
      ,TO_DATE(PAA.ATTRIBUTE4,'YYYY/MM/DD HH24:MI:SS')
  FROM per_absence_attendances_v paa
 WHERE paa.absence_attendance_id = 9298325 --9584338
   UNION
SELECT 'FECHA_FINAL'
      ,PAA.ATTRIBUTE5
      ,TO_DATE(PAA.ATTRIBUTE5,'YYYY/MM/DD HH24:MI:SS')
  FROM per_absence_attendances_v paa
 WHERE paa.absence_attendance_id = 9298325 --9584338
;
SELECT *
  FROM per_absence_attendances_v paa
 WHERE paa.ab
9298325

  SELECT pet.element_name
        ,piv.input_value_id
        ,piv.name AS input_name
  FROM  xxmupay_element_types_v pet
       ,xxmu_pay_input_values piv
  WHERE piv.element_type_id = pet.element_type_id
  AND   pet.element_name LIKE '%1600'
  ;
  
  SELECT pet.element_name
        ,piv.name AS input_name
        ,piv.input_value_id
    FROM  pay_element_types_x pet
         ,pay_input_values_x piv
   WHERE pet.element_name LIKE 'I_1600'
     AND piv.element_type_id = pet.element_type_id
       AND   piv.uom = 'D'
  ;
  
  
SELECT *
FROM   pay_element_entries_f pee
WHERE  pee.creator_id = 9584338
;

SELECT pet.element_name, pet.reporting_name
FROM   PAY_ELEMENT_TYPES_X pet
WHERE  pet.element_name LIKE 'I_1720' --'I_1690' --'I_1684' --'I_1680' --'I_1675' --'I_1650' --'I_1625' --'I_1620' --'I_1600' --'I_0911'
--'D_2124' --'D_2110' --'A_1730' --'A_0780' --'A_0775' --'A_0740' --'A_0690' --'A_0660' --'A_0740' -- 'A_0660' --'A_0650' --'A_0625'--'I_1600'
;



SELECT * --CUSTOM_ID
  --into vnCustomId
  FROM XX_CUSTOM_HEADERS
 WHERE CUSTOM_CODE = 'XXMU_PAY_ABSENCE_DIST'
 ;
SELECT *
FROM   XX_CUSTOM_DETAILS
WHERE  custom_id = 324
;



-->>>>>
/*BEGIN
  pn_days_factor NUMBER := (&p_date_start - &p_flex_start)*-1;
  pd_flex_start_date_loop  :=  fffunc.add_days(DATE_START, pn_days_factor)
  
  IF (pd_flex_start_date_loop BETWEEN TO_DATE(TO_CHAR(DATE_START('YYYY/MM')||'/01', 'YYYY/MM/DD') AND fffunc.add_days(v_start_date, v_dias_ingresar)) THEN
       IF (fffunc.add_days(v_start_date, v_dias_ingresar) BETWEEN DATE_START_FLEX AND DATE_END_FLEX THEN
           pd_flex_end_date := fffunc.add_days(fffunc.add_days(v_start_date, v_dias_ingresar), pn_days_factor);
       ELSIF () THEN
       END IF;
  END IF;
END;
  pn_days_factor := -5;
  pd_flex_start_date_loop := 11-ene-2017;
  v_start_date := 16-ene-2017;
  LOOP
    v_end_date := 17-ene-2017;
  
  IF pd_flex_start_date_loop BETWEEN v_start_date AND v_end_date THEN
    
    IF ELEMENT_NAME = 'A_0740' THEN
    
    ELSE
      --FIN PERIODO ENTRE RANGO AUSENCIA
        
    END IF;
    END IF;  
    
ELEMENT_NAME      A_0740       A_0660
DIST_DAYS         2            
DIST_START_DATE   16-ene-2017  18-ene-2017
DIST_END_DATE     17-ene-2017  29-ene-2017
FLEX_START_DATE   11-ene-2017  11-ene-2017
FLEX_END_DATE     04-feb-2017  04-feb-2017


--GET_FACTOR_DAYS 
pn_days_factor NUMBER := (DIST_START_DATE - FLEX_START_DATE)*-1;
--A_0740 := -5 -> [16-ene-2017 - 11-ene-2017]*-1
--A_0660 := -7 -> [18-ene-2017 - 11-ene-2017]*-1
IF A_0740 THEN
  pd_flex_start_date_loop := 11-ENE-2017/*fffunc.add_days(DIST_START_DATE, pn_days_factor)*/;
  pd_flex_end_date_loop   := 12-ENE-2017/*fffunc.add_days(DIST_END_DATE  , pn_days_factor);*/
ELSE
  --WHEN BETWEEN A_1740  -> ADD fffunc.add_days( pd_flex_start_date_loop, get_global_value('GM_CO_AUX_INC_PRIMEROS_DIAS'));
  pd_flex_start_date_loop := 11-ENE-2017/*fffunc.add_days(DIST_START_DATE, pn_days_factor)*/;
  IF IS_A_1740_PARTNER THEN
    pd_flex_start_date_loop := 13-ENE-2017/*fffunc.add_days( pd_flex_start_date_loop, get_global_value('GM_CO_AUX_INC_PRIMEROS_DIAS'))*/;
  END IF;

  IF PERIOD_END_DATE BETWEEN FLEX_START_DATE AND FLEX_END_DATE THEN
    pd_flex_end_date_loop   := 31-ENE-2017/*fffunc.add_days(DIST_END_DATE  , pn_days_factor)*/;
  END IF;
END IF;


SELECT ptp.start_date
      ,ptp.end_date
  FROM per_time_periods ptp
 WHERE ptp.payroll_id = 181 --p_payroll_id
   AND TRUNC(NVL(&p_fecha, SYSDATE)) BETWEEN ptp.start_date AND end_date
   ;

--  DECADAL: 
--QUINCENAL:
--  MENSUAL:

IF TO_CHAR(FLEX_START_DATE, 'MM') = TO_CHAR(DATE_START, 'MM') THEN --SOLO AUSENCIAS QUE SE DISTRIBUYEN EL MISMO MES
  IF (V_START_DATE = DATE_START) THEN --PRIMER CICLO
     --CASO1
     IF FLEX_END_DATE <= V_START_DATE THEN
       pd_flex_start_date := flex_start_date;
       pd_flex_end_date := flex_end_date;
     END IF;

     --CASO2
     IF FLEX_END_DATE <= PERIOD_END_DATE THEN 
       pd_flex_start_date := flex_start_date;
       pd_flex_end_date := flex_end_date;
     END IF;

     --CAS03            
     IF FLEX_END_DATE > PERIOD_END_DATE THEN
       pd_flex_start_date := flex_start_date;
       pd_flex_end_date := period_end_date;
     END IF;

  ELSE
     IF V_START_DATE BETWEEN FLEX_START_DATE AND FLEX_END_DATE THEN
       pd_flex_start_date := v_start_date;
       
       IF FLEX_END_DATE > PERIOD_END_DATE THEN
          pd_flex_end_date := period_end_date;
       ELSE
          pd_flex_end_date := flex_end_date;
       END IF;
     END IF;
     
  END IF;

END IF;


 SELECT paa.date_start init_real_date
            ,paa.date_end final_real_date
            ,TO_DATE(paa.attribute4,'YYYY/MM/DD HH24:MI:SS') init_date
            ,TO_DATE(paa.attribute5,'YYYY/MM/DD HH24:MI:SS') final_date
        FROM per_absence_attendances_v paa
       WHERE paa.absence_attendance_id = 9588336;

--21/01/2017	REAL_INIT_DATE
--02/02/2017	REAL_FINAL_DATE
--23/01/2017	FLEX_INIT_DATE
--04/02/2017  FLEX_FINAL_DATE

23-24 ene A_0740 16-31 enero
25-31 ene A_0660 16-31 enero
01-04 ene A_0660 01-15 enero

DECLARE
  vd_flex_init_date DATE;
  vd_flex_final_date DATE;
  vd_start_date DATE;
  vd_final_date DATE;
  vv_status VARCHAR2(4000);
BEGIN
  
  xxmu_hr_utils3_pk.get_document_dates(pn_in_absence_attendance_id => 9592356
                                      ,pd_in_payroll_id => 181
                                      ,pd_in_effective_date => TO_DATE('09/02/2017', 'DD/MM/YYYY')
                                      ,pn_in_absence_days => 5
                                      ,pv_in_process_code => 'NORMAL'--'A_0740_1650_BROTHER' --'A_0740_1650'--
                                      ,pd_out_start_date => vd_start_date
                                      ,pd_out_end_date => vd_final_date
                                      ,pd_out_flex_start_date => vd_flex_init_date
                                      ,pd_out_flex_final_date => vd_flex_final_date
                                      ,pv_out_status => vv_status);
  dbms_output.put_line('pd_out_start_date: '||vd_start_date);
  dbms_output.put_line('pd_out_end_date: '||vd_final_date);
  dbms_output.put_line('pd_out_flex_start_date: '||vd_flex_init_date);
  dbms_output.put_line('pd_out_flex_final_date: '||vd_flex_final_date);
  dbms_output.put_line('pv_out_status: '||vv_status);
END;



SELECT fffunc.add_days(datevar => TO_DATE('2017/01/11', 'YYYY/MM/DD'), days => 2)
FROM dual;

SELECT pet.element_name, piv.name AS input_name, pev.screen_entry_value, pev.*
FROM   pay_element_entries_f pee
      ,pay_element_entry_values_f pev
      ,pay_element_types_x pet
      ,pay_input_values_x piv
WHERE  pee.creator_id = 9593337 --9593336 --9593334
AND    pev.element_entry_id = pee.element_entry_id
AND    pet.element_type_id = pee.element_type_id
AND    piv.input_value_id = pev.input_value_id
ORDER BY pev.element_entry_value_id, pet.element_name, piv.display_sequence
;
