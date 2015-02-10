  --****************************************************************
  -- Procedure: invoke_webservice
  --
  -- Description: Invokes a webservice method via UTL_HTTP
  --
  -- Parameters:
  --  p_name_space - IN - the xml namespace for the operation  
  --  p_operation_name - IN - The  name for the operation.
  --  p_wsdl_url - IN - The URL for the WSDL document location for the service
  --  p_parameters - IN - array list of parameters to pass to the webservice (t_avchar2 is a VARRAY of VARCHAR2)
  --  p_parameter_types - IN array of the types of the parameters.
  --
  -- Returns
  --   VARCHAR2 - the serialized response from the service
  --
  --****************************************************************    
  FUNCTION invoke_webservice(p_name_space IN VARCHAR2,
                             p_operation_name IN VARCHAR2,
                             p_wsdl_url IN VARCHAR2,
                             p_parameters IN t_avchar2,
                             p_parameter_types IN t_avchar2)
  RETURN VARCHAR2
  IS
    l_soap      VARCHAR2(4000);  
    l_result    VARCHAR2(4000);    
    l_request   UTL_HTTP.req;
    l_response  UTL_HTTP.resp;    
  BEGIN
    
    -- Generate the SOAP envelope - start with header
    l_soap := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' ||
               'xmlns:q0="' || p_name_space || '" ' ||
               'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' ||
               'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> ' ||
             '<soapenv:Body> ' ||
               '<q0:' || p_operation_name || ' > ';
               
    -- If there are any parameters, add them now:
    IF p_parameters.EXISTS(1) THEN
    
      FOR i IN p_parameters.FIRST..p_parameters.LAST
      LOOP
        l_soap := l_soap || '<arg' || (i-1) || ' xsi:type="xs:' || p_parameter_types(i) ||'">' || 
                                      p_parameters(i) || '</arg' || (i-1) ||'>';         
      END LOOP;
    
    END IF;
               
    -- Finish off the envelope.
    l_soap := l_soap ||     
               '</q0:' || p_operation_name || ' > ' ||
             '</soapenv:Body> ' ||
           '</soapenv:Envelope> ';    
   
    -- Request
    BEGIN
      -- Start the http request off (establishes the connection to the server)
      l_request := UTL_HTTP.begin_request(p_wsdl_url, 'POST','HTTP/1.1');
      
      -- Set header details for the request. (Host header is auto set by UTL_HTTP since we're using HTTP 1.1)
      UTL_HTTP.set_header(l_request, 'Content-Type', 'text/xml');
      UTL_HTTP.set_header(l_request, 'Content-Length', LENGTH(l_soap));
      
      -- Write the soap envelope text to the service
      UTL_HTTP.write_text(l_request, l_soap);
      
      -- Get the answer from the service
      l_response := UTL_HTTP.get_response(l_request);
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Terminate the request and re-raise
        UTL_HTTP.end_request(l_request);
        RAISE;
    END;

    -- Response
    BEGIN
      -- Read the response into the result envelope and close the connection
      UTL_HTTP.read_text(l_response, l_result);
      UTL_HTTP.end_response(l_response);
    EXCEPTION
      WHEN OTHERS THEN    
        -- Terminate the response and re-raise
        UTL_HTTP.end_response(l_response);
        RAISE;
    END;
    
    RETURN l_result;
      
  END invoke_webservice; 
