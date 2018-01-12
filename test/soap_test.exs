defmodule SoapTest do
  use ExUnit.Case
  doctest Soap
  import Mock
  alias Soap.Wsdl

  @soap_action "sendMessage"
  @request_params %{inCommonParms: [{"userID", "WSPB"}]}

  test "#call was success" do
    {_, wsdl}   = Fixtures.get_file_path("wsdl/SendService.wsdl") |> Wsdl.parse_from_file
    http_poison_result = {:ok, %HTTPoison.Response{status_code: 200, body: "Anything"}}

    with_mock(HTTPoison, [post!: fn(_, _, _) -> http_poison_result end]) do
      {_, response} = http_poison_result
      assert(Soap.call(wsdl, @soap_action, @request_params) == {:ok, response.body})
    end
  end

  test "#call was success, but not found" do
    {_, wsdl}   = Fixtures.get_file_path("wsdl/SendService.wsdl") |> Wsdl.parse_from_file
    http_poison_result = {:ok, %HTTPoison.Response{status_code: 404}}

    with_mock(HTTPoison, [post!: fn(_, _, _) -> http_poison_result end]) do
      assert(Soap.call(wsdl, @soap_action, @request_params) == {:error, "Not found"})
    end
  end

  test "#call returns error" do
    {_, wsdl}   = Fixtures.get_file_path("wsdl/SendService.wsdl") |> Wsdl.parse_from_file
    http_poison_result = {:error, %HTTPoison.Error{reason: :something_wrong}}

    with_mock(HTTPoison, [post!: fn(_, _, _) -> http_poison_result end]) do
      assert(Soap.call(wsdl, @soap_action, @request_params) == {:error, :something_wrong})
    end
  end
end
