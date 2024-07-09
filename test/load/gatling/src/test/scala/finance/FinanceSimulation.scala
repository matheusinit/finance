package finance

import scala.concurrent.duration._

import scala.util.Random

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.core.feeder._

class FinanceSimulation extends Simulation {

  val baseURL = "http://0.0.0.0:8080"

  val httpProtocol = http
    .baseUrl(baseURL)
    .acceptHeader("application/json, text/javascript, */*; q=0.01")
    .acceptEncodingHeader("gzip, deflate")
    .acceptLanguageHeader("en-US,en;q=0.5")
    .userAgentHeader(
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0"
    )

  // val getCSRFToken = http("Get CSRF Token")
    // .get("/csrf_token")
    // .check(status.is(200))
    // .check(
      // jsonPath("$.csrf_token").saveAs("csrfToken")
      // css("meta[name='csrf-token']", "content").saveAs("csrfToken")
    // )

  val createUser = http("Create user")
    .post("/user/new")
    // .header("x-csrf-token", "#{csrf_token}")
    .header("content-type", "application/x-www-form-urlencoded")
    .formParam("name", "#{name}")
    .formParam("email", "#{email}")
    .formParam("password", "#{password}")
    .formParam("password_confirmation", "#{password_confirmation}")
    .check(status.in(201))

  val data = csv("users.csv").circular()

  val users = scenario("Creation of accounts")
    .feed(data)
    // .exec(getCSRFToken)
    .exec(createUser)
    // .pause(1.milliseconds, 30.milliseconds)

  setUp(
    users.inject(
      constantUsersPerSec(2).during(10.seconds),
      constantUsersPerSec(5).during(15.seconds).randomized,

      rampUsersPerSec(10).to(500).during(2.minutes)
    )
  ).protocols(httpProtocol)
}
