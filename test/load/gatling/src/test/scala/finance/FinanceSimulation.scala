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

  val createUser = http("Create user")
    .post("/user/new")
    .header("content-type", "application/x-www-form-urlencoded")
    .formParam("name", "#{name}")
    .formParam("email", "#{email}")
    .formParam("password", "#{password}")
    .formParam("password_confirmation", "#{password_confirmation}")
    .check(status.in(201, 422, 400))

  val creationUserData = csv("create-users-data.csv").circular()

  val users = scenario("Creation of accounts")
    .feed(creationUserData)
    .exec(createUser)

  val loginUser = http("Login user")
    .post("/api/login")
    .header("content-type", "application/x-www-form-urlencoded")
    .formParam("email", "#{email}")
    .formParam("password", "#{password}")
    .check(status.in(200))

  val loginUserData= csv("login-users-data.csv").circular()

  val loginUsers = scenario("Login users with prepared data")
    .feed(loginUserData)
    .exec(loginUser)

  setUp(
    users.inject(
      constantUsersPerSec(2).during(10.seconds),
      constantUsersPerSec(5).during(15.seconds).randomized,

      rampUsersPerSec(10).to(225).during(1.minutes)
    ).andThen(
      loginUsers.inject(
        constantUsersPerSec(2).during(10.seconds),
        constantUsersPerSec(5).during(15.seconds).randomized,

        rampUsersPerSec(10).to(225).during(1.minutes)
    ))
  ).protocols(httpProtocol)
}
