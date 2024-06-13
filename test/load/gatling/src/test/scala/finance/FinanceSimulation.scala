package finance

import scala.concurrent.duration._

import scala.util.Random

import io.gatling.core.Predef._
import io.gatling.http.Predef._

class FinanceSimulation extends Simulation {

  val baseURL = "http://localhost:3000"

  val httpProtocol = http
    .baseUrl(baseURL)
    .inferHtmlResources()
    .acceptHeader("application/json, text/javascript, */*; q=0.01")
    .acceptEncodingHeader("gzip, deflate")
    .acceptLanguageHeader("en-US,en;q=0.5")
    .userAgentHeader(
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0"
    )

  val accountsCreation = scenario("Creation of accounts")
    .exec(
      http("Get CSRF Token")
        .get("/user/new")
        .check(status.is(200))
        .check(
          css("meta[name='csrf-token']", "content").saveAs("csrfToken")
        )
    )
    .exec(
      http("Create user")
        .post("/user/new")
        .header("x-csrf-token", "#{csrfToken}")
        .header("content-type", "application/x-www-form-urlencoded")
        .formParam("name", "Matheus Oliveira")
        .formParam("email", "matheus13@email.com")
        .formParam("password", "Pandaninja13.")
        .formParam("password_confirmation", "Pandaninja13.")
        .check(status.in(201, 422, 400, 500))
    )
    .pause(1.milliseconds, 30.milliseconds)

  setUp(
    accountsCreation.inject(
      constantUsersPerSec(2).during(5.seconds)
    )
  ).protocols(httpProtocol)
}
