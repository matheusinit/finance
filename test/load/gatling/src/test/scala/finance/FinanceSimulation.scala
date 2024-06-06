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
      http("Get CSRF token")
        .get("/csrf_token")
        .check(
          jsonPath("$.csrf_token").saveAs("csrfToken"),
          header("Set-Cookie").saveAs("setCookieHeader")
        )
    )
    .pause(1)
    // .feed(tsv("pessoas-payloads.tsv").circular())
    .exec(
      http("Create user")
        .post("/user/new")
        // .body(StringBody("#{payload}"))
        // .header("content-type", "application/x-www-form-urlencoded")
        .header("X-CSRF-Token", "${csrfToken}")
        .header("Cookie", "${setCookieHeader}")
        .formParam("name", "Matheus Oliveira")
        .formParam("email", "matheus1@email.com")
        .formParam("password", "Pandaninja13.")
        // 201 pros casos de sucesso :)
        // 422 pra requests inválidos :|
        // 400 pra requests bosta tipo data errada, tipos errados, etc. :(
        .check(status.in(201, 422, 400, 500))
        // Se a criacao foi na api1 e esse location request atingir api2, a api2 tem que encontrar o registro.
        // Pode ser que o request atinga a mesma instancia, mas estatisticamente, pelo menos um request vai atingir a outra.
        // Isso garante o teste de consistencia de dados
        .check(status.saveAs("httpStatus"))
        .checkIf(session => session("httpStatus").as[String] == "201") {
          header("Location").saveAs("location")
        }
    )
    .pause(1.milliseconds, 30.milliseconds)

  setUp(
    accountsCreation.inject(
      constantUsersPerSec(2).during(10.seconds), // warm up
      constantUsersPerSec(5).during(15.seconds).randomized, // are you ready?
      rampUsersPerSec(6).to(10).during(3.minutes) // lezzz go!!!
    )
  ).protocols(httpProtocol)
}
