create or replace package utw_tsip_iface_bainfo_pkg as
  /* 
  UnitTest wrapper for tsip_iface_bainfo_pkg
  */

  --(method){1,27}_(overload){2}
  procedure getBAInfoList
  (
    p_xml_in  in xmltype,
    p_xml_out out nocopy xmltype
  );

end;
/
create or replace package body utw_tsip_iface_bainfo_pkg as

  procedure getBAInfoList
  (
    p_xml_in  in xmltype,
    p_xml_out out nocopy xmltype
  ) is
    l_params_in  uti_tsip_iface004getbainfol001;
    l_params_out uto_tsip_iface004getbainfol001 := uto_tsip_iface004getbainfol001();
    --
    --TODO: for all sys_refcursor params
    l_crs_a_bainfolist sys_refcursor;
  begin
    --
    --create input params object from xml
    p_xml_in.toobject(object => l_params_in);
    --
    --TODO: for all in/out params
    --set inout parameters in output params object
    l_params_out.p_operation_id := l_params_in.p_operation_id;
    l_params_out.a_startindex   := l_params_in.a_startindex;
    --
    --call method
    tsip_iface_bainfo_pkg.getbainfolist(p_operation_id => l_params_out.p_operation_id,
                                        a_channelcode  => l_params_in.a_channelcode,
                                        a_languagecode => l_params_in.a_languagecode,
                                        a_username     => l_params_in.a_username,
                                        --
                                        a_balancetypes   => l_params_in.a_balancetypes,
                                        a_mcalist        => l_params_in.a_mcalist,
                                        a_filterusername => l_params_in.a_filterusername,
                                        --
                                        a_maxresults   => l_params_in.a_maxresults,
                                        a_startindex   => l_params_out.a_startindex,
                                        a_endindex     => l_params_out.a_endindex,
                                        a_endofrecords => l_params_out.a_endofrecords,
                                        --
                                        a_bainfolist => l_crs_a_bainfolist,
                                        --
                                        result_code => l_params_out.result_code,
                                        error_code  => l_params_out.error_code,
                                        error_desc  => l_params_out.error_desc);
    --
    l_params_out.a_bainfolist := xmltype.createxml(l_crs_a_bainfolist);
    --
    --convert output parameters object to xml
    p_xml_out := xmltype.createxml(xmlData => l_params_out);
  end;

end;
/
