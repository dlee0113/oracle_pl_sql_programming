  --****************************************************************
  -- Procedure: invoke_webservice 
  --
  -- Description: Invokes a webservice method vai UTL_DBWS
  --
  --  Note - no error handler - deal with exceptions further up the stack
  --
  -- Parameters:
  --  p_wsdl_url - IN - The URL for the WSDL document location for the service
  --  p_service_name - IN  - The qualified name for the service.
  --  p_operation_name - IN - The qualified name for the operation.
  --  p_request - IN - the serialized request to make to the service
  --
  -- Returns
  --   VARCHAR2 - the seriliazed response from the service
  --
  --****************************************************************    
  FUNCTION invoke_webservice(p_wsdl_url IN VARCHAR2,
                             p_service_name IN VARCHAR2,
                             p_operation_name IN VARCHAR2,
                             p_request_string IN VARCHAR2)
  RETURN VARCHAR2
  IS
    l_service  UTL_DBWS.service;
    l_call     UTL_DBWS.call;
    l_request  SYS.XMLTYPE;
    l_response SYS.XMLTYPE;
    l_result   VARCHAR2(4000);
  BEGIN
  
    -- Create an XMLType for the request and log it
    l_request := sys.XMLTYPE(p_request_string);
    
    -- Create the service instance
    l_service := UTL_DBWS.create_service (  wsdl_document_location => URIFACTORY.getURI(p_wsdl_url),
                                            service_name           => p_service_name);
    
    -- Create a call instance
    l_call := UTL_DBWS.create_call (  service_handle => l_service,
                                      port_name      => NULL,
                                      operation_name => p_operation_name);
    
    -- Invoke the webservice
    l_response := UTL_DBWS.invoke ( call_handle  => l_call,
                                    request => l_request);

    -- Extract the string value of the response and log it                         
    l_result := l_response.getstringval; 
    
    -- Clear up
    UTL_DBWS.release_call (call_handle => l_call);
    UTL_DBWS.release_service (service_handle => l_service);

    RETURN l_result;

  END invoke_webservice; 