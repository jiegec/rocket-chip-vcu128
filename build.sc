import mill._
import mill.scalalib.publish._
import scalalib._
import scalafmt._
import coursier.maven.MavenRepository
import $ivy.`com.goyeau::mill-scalafix_mill0.11:0.3.1`
import com.goyeau.mill.scalafix.ScalafixModule

// learned from https://github.com/OpenXiangShan/fudian/blob/main/build.sc
val defaultVersions = Map(
  "chisel" -> ("org.chipsalliance", "6.6.0", false),
  "chisel-plugin" -> ("org.chipsalliance", "6.6.0", true),
  "json4s-jackson" -> ("org.json4s", "4.0.6", false),
  "chiseltest" -> ("edu.berkeley.cs", "0.6.0-RC3", false),
  "scalatest" -> ("org.scalatest", "3.2.15", false),
  "sourcecode" -> ("com.lihaoyi", "0.3.1", false),
  "mainargs" -> ("com.lihaoyi", "0.5.0", false),
)

val commonScalaVersion = "2.13.15"

def getVersion(dep: String) = {
  val (org, ver, cross) = defaultVersions(dep)
  val version = sys.env.getOrElse(dep + "Version", ver)
  if (cross)
    ivy"$org:::$dep:$version"
  else
    ivy"$org::$dep:$version"
}

trait CommonModule extends ScalaModule {
  def scalaVersion = commonScalaVersion

  // for snapshot dependencies
  override def repositoriesTask = T.task {
    super.repositoriesTask() ++ Seq(
      MavenRepository("https://oss.sonatype.org/content/repositories/snapshots")
    )
  }

  // for scalafix rules
  override def scalacOptions =
    Seq("-Ywarn-unused", "-deprecation")
}

object hardfloat extends CommonModule with SbtModule {
  override def millSourcePath =
    os.pwd / "submodules" / "berkeley-hardfloat" / "hardfloat"

  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("chisel")
  )

  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("chisel-plugin")
  )
}

object apiConfigChipsalliance extends CommonModule {
  override def millSourcePath =
    os.pwd / "submodules" / "api-config-chipsalliance" / "cde"
}

object diplomacy extends CommonModule with ScalaModule {
  override def millSourcePath =
    os.pwd / "submodules" / "diplomacy" / "diplomacy"

  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("chisel"),
    getVersion("sourcecode"),
  )

  override def moduleDeps =
    super.moduleDeps ++ Seq(
      apiConfigChipsalliance
    )

  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("chisel-plugin")
  )
}

object rocketChipMacros extends CommonModule {
  override def millSourcePath = os.pwd / "submodules" / "rocket-chip" / "macros"

  override def ivyDeps = super.ivyDeps() ++ Agg(
    ivy"org.scala-lang:scala-reflect:$commonScalaVersion"
  )
}

object rocketChip extends CommonModule with SbtModule {
  override def millSourcePath = os.pwd / "submodules" / "rocket-chip"

  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("chisel"),
    getVersion("mainargs"),
    getVersion("json4s-jackson"),
    ivy"org.scala-lang:scala-reflect:$commonScalaVersion"
  )

  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("chisel-plugin")
  )

  override def moduleDeps =
    super.moduleDeps ++ Seq(
      hardfloat,
      rocketChipMacros,
      apiConfigChipsalliance,
      diplomacy
    )

  override def scalacOptions = super.scalacOptions() ++
    Seq("-deprecation", "-unchecked")
}

object boom extends CommonModule with SbtModule {
  override def millSourcePath = os.pwd / "submodules" / "riscv-boom"
  override def moduleDeps = super.moduleDeps ++ Seq(rocketChip)
  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("chisel-plugin")
  )
}

object inclusiveCache extends CommonModule with ScalaModule {
  override def millSourcePath =
    os.pwd / "submodules" / "rocket-chip-inclusive-cache" / "design" / "craft" / "inclusivecache"
  override def moduleDeps = super.moduleDeps ++ Seq(rocketChip)
  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("chisel-plugin")
  )
}

object vcu128 extends CommonModule with ScalafmtModule {
  override def millSourcePath = os.pwd

  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("chisel"),
    getVersion("chiseltest")
  )

  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("chisel-plugin")
  )

  override def moduleDeps =
    super.moduleDeps ++ Seq(
      apiConfigChipsalliance,
      rocketChip,
      boom,
      inclusiveCache
    )

  object test extends ScalaTests with TestModule.ScalaTest {
    override def ivyDeps = super.ivyDeps() ++ Agg(
      getVersion("scalatest")
    )
  }
}
