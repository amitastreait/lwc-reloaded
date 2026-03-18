/**
 * @description Test utility class providing REST context setup and HTTP callout
 *              mock helpers. All methods are static — this class is never instantiated.
 *
 *              Eliminates the 6-line RestRequest/RestResponse boilerplate that was
 *              copy-pasted in every test method of AccountContactRestServiceTest.
 *
 * Usage examples:
 *   // Simplest — uses the AccountContactRestService default URI + POST
 *   TestContextHelper.setupRestContext();
 *
 *   // Custom endpoint for a different REST service
 *   TestContextHelper.setupRestContext('/services/apexrest/api/flights/', 'GET');
 *
 *   // Stripe happy-path mock (register before Test.startTest())
 *   TestContextHelper.registerStripeSuccessMock();
 *
 * @author Salesforce Developer
 * @date 2026-03-18
 */
@isTest
public class TestContextHelper {

    // Default URI and method matching AccountContactRestService's @RestResource mapping
    private static final String DEFAULT_URI    = '/services/apexrest/api/accountcontact/';
    private static final String DEFAULT_METHOD = 'POST';


    // =========================================================================
    // REST CONTEXT SETUP
    // =========================================================================

    /**
     * Sets up a minimal REST context using the AccountContactRestService default
     * URI (/services/apexrest/api/accountcontact/) and HTTP method POST.
     *
     * Replaces this repeated block:
     *   RestRequest request = new RestRequest();
     *   RestResponse response = new RestResponse();
     *   request.requestURI = '/services/apexrest/api/accountcontact/';
     *   request.httpMethod = 'POST';
     *   RestContext.request = request;
     *   RestContext.response = response;
     */
    public static void setupRestContext() {
        setupRestContext(DEFAULT_URI, DEFAULT_METHOD);
    }

    /**
     * Sets up a REST context for any URI and HTTP method.
     * Use this when testing REST services other than AccountContactRestService.
     *
     * @param uri        The request URI (e.g. '/services/apexrest/api/flights/')
     * @param httpMethod The HTTP method (e.g. 'GET', 'POST', 'PUT', 'DELETE')
     */
    public static void setupRestContext(String uri, String httpMethod) {
        RestRequest  req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI  = uri;
        req.httpMethod  = httpMethod;
        RestContext.request  = req;
        RestContext.response = res;
    }

    /**
     * Sets up a REST context with a pre-serialized JSON body.
     * Use this when the service reads from RestContext.request.requestBody
     * rather than accepting a typed Apex parameter.
     *
     * @param uri        The request URI
     * @param httpMethod The HTTP method
     * @param bodyObject Any Apex object — will be JSON-serialized into the request body
     */
    public static void setupRestContextWithBody(String uri, String httpMethod, Object bodyObject) {
        setupRestContext(uri, httpMethod);
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(bodyObject));
        RestContext.request.addHeader('Content-Type', 'application/json');
    }

    /**
     * Adds an HTTP header to the current RestContext request.
     * Must be called AFTER setupRestContext().
     *
     * @param key   Header name (e.g. 'Authorization')
     * @param value Header value (e.g. 'Bearer token123')
     */
    public static void addRequestHeader(String key, String value) {
        RestContext.request.addHeader(key, value);
    }

    /**
     * Returns the HTTP status code that the service set on the REST response.
     * Useful for asserting correct response codes (e.g. 200, 400, 500).
     *
     * @return Integer status code, or null if not yet set by the service
     */
    public static Integer getResponseStatusCode() {
        return RestContext.response.statusCode;
    }


    // =========================================================================
    // HTTP CALLOUT MOCK: Stripe
    // =========================================================================

    /**
     * Registers a configurable HttpCalloutMock for Stripe API calls.
     * Call this before Test.startTest() in any test that exercises
     * StripePaymentService.getPaymentIntentClientSecret().
     *
     * @param statusCode   HTTP status code to return (e.g. 200, 402)
     * @param responseBody Raw response body string (typically JSON)
     */
    public static void registerStripeMock(Integer statusCode, String responseBody) {
        Test.setMock(HttpCalloutMock.class, new MockStripeHttpResponse(statusCode, responseBody));
    }

    /**
     * Registers a standard Stripe success response (HTTP 200) with a synthetic
     * payment_intent object including a client_secret.
     * Zero-config convenience for happy-path Stripe tests.
     */
    public static void registerStripeSuccessMock() {
        String body = JSON.serialize(new Map<String, Object>{
            'id'            => 'pi_test_' + UUID.randomUUID().toString(),
            'object'        => 'payment_intent',
            'amount'        => 9999,
            'currency'      => 'usd',
            'status'        => 'requires_payment_method',
            'client_secret' => 'pi_test_secret_' + UUID.randomUUID().toString()
        });
        registerStripeMock(200, body);
    }

    /**
     * Registers a Stripe failure response (HTTP 402) simulating a declined card.
     * Use this to test error-handling branches in StripePaymentService.
     */
    public static void registerStripeFailureMock() {
        String body = JSON.serialize(new Map<String, Object>{
            'error' => new Map<String, Object>{
                'type'    => 'card_error',
                'code'    => 'card_declined',
                'message' => 'Your card was declined.'
            }
        });
        registerStripeMock(402, body);
    }


    // =========================================================================
    // INNER CLASS: MockStripeHttpResponse
    // =========================================================================

    /**
     * @description Configurable HttpCalloutMock for Stripe API calls.
     *              Simulates any combination of HTTP status code and response body.
     *              Used internally by registerStripeMock(), registerStripeSuccessMock(),
     *              and registerStripeFailureMock().
     */
    public class MockStripeHttpResponse implements HttpCalloutMock {

        private Integer statusCode;
        private String  responseBody;

        public MockStripeHttpResponse(Integer statusCode, String responseBody) {
            this.statusCode   = statusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            response.setBody(responseBody);
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }
}
