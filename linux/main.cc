#include <miso/miso.h>

int main(int argc, char** argv) {
  return g_application_run(G_APPLICATION(miso_application_new(APPLICATION_ID)), argc, argv);
}
