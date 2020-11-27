import scala.sys.process._

object EInStyleWrapper extends App {
  List("ACGAN", "BEGAN", "CGAN", "DRAGAN", "EBGAN", "GAN", "infoGAN", "LSGAN", "WGAN", "WGAN_GP")
    .foreach(ganType => f"sbatch --export=ALL,GAN_TYPE=$ganType e-in-style.sh"!)
}
